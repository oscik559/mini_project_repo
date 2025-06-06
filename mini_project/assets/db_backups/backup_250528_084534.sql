--
-- PostgreSQL database dump
--

-- Dumped from database version 17.3
-- Dumped by pg_dump version 17.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: access_logs; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.access_logs (
    log_id integer NOT NULL,
    user_id integer NOT NULL,
    action_type text NOT NULL,
    target_table text,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.access_logs OWNER TO oscar;

--
-- Name: camera_vision; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.camera_vision (
    object_id integer NOT NULL,
    object_name text NOT NULL,
    object_color text NOT NULL,
    color_code double precision[],
    pos_x double precision NOT NULL,
    pos_y double precision NOT NULL,
    pos_z double precision NOT NULL,
    rot_x double precision NOT NULL,
    rot_y double precision NOT NULL,
    rot_z double precision NOT NULL,
    usd_name text NOT NULL,
    last_detected timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.camera_vision OWNER TO oscar;

--
-- Name: camera_vision_object_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.camera_vision_object_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.camera_vision_object_id_seq OWNER TO oscar;

--
-- Name: camera_vision_object_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.camera_vision_object_id_seq OWNED BY public.camera_vision.object_id;


--
-- Name: drop_op_parameters; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.drop_op_parameters (
    sequence_id integer NOT NULL,
    operation_order integer NOT NULL,
    object_id text NOT NULL,
    drop_height double precision NOT NULL,
    drop_pos_x double precision,
    drop_pos_y double precision,
    drop_pos_z double precision,
    operation_status boolean NOT NULL
);


ALTER TABLE public.drop_op_parameters OWNER TO oscar;

--
-- Name: drop_op_parameters_sequence_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.drop_op_parameters_sequence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.drop_op_parameters_sequence_id_seq OWNER TO oscar;

--
-- Name: drop_op_parameters_sequence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.drop_op_parameters_sequence_id_seq OWNED BY public.drop_op_parameters.sequence_id;


--
-- Name: gesture_instructions; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.gesture_instructions (
    id integer NOT NULL,
    session_id text NOT NULL,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    gesture_text text NOT NULL,
    natural_description text,
    confidence real,
    hand_label text,
    processed boolean DEFAULT false
);


ALTER TABLE public.gesture_instructions OWNER TO oscar;

--
-- Name: gesture_instructions_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

ALTER TABLE public.gesture_instructions ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.gesture_instructions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: gesture_library; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.gesture_library (
    id integer NOT NULL,
    gesture_type text NOT NULL,
    gesture_text text NOT NULL,
    natural_description text,
    config jsonb
);


ALTER TABLE public.gesture_library OWNER TO oscar;

--
-- Name: gesture_library_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

ALTER TABLE public.gesture_library ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.gesture_library_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: instruction_operation_sequence; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.instruction_operation_sequence (
    task_id integer NOT NULL,
    instruction_id integer,
    skill_id integer,
    skill_name text,
    sequence_id integer,
    sequence_name text NOT NULL,
    object_id integer,
    object_name text,
    status text DEFAULT 'pending'::text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT instruction_operation_sequence_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'in_progress'::text, 'completed'::text, 'failed'::text])))
);


ALTER TABLE public.instruction_operation_sequence OWNER TO oscar;

--
-- Name: instruction_operation_sequence_task_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.instruction_operation_sequence_task_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.instruction_operation_sequence_task_id_seq OWNER TO oscar;

--
-- Name: instruction_operation_sequence_task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.instruction_operation_sequence_task_id_seq OWNED BY public.instruction_operation_sequence.task_id;


--
-- Name: instructions; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.instructions (
    id integer NOT NULL,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    user_id integer,
    modality text,
    language text NOT NULL,
    instruction_type text NOT NULL,
    processed boolean DEFAULT false,
    content text,
    sync_id integer,
    confidence real,
    CONSTRAINT instructions_confidence_check CHECK (((confidence >= (0)::double precision) AND (confidence <= (1)::double precision))),
    CONSTRAINT instructions_modality_check CHECK ((modality = ANY (ARRAY['voice'::text, 'gesture'::text, 'text'::text])))
);


ALTER TABLE public.instructions OWNER TO oscar;

--
-- Name: instructions_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

ALTER TABLE public.instructions ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.instructions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: interaction_memory; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.interaction_memory (
    interaction_id integer NOT NULL,
    user_id integer,
    instruction_id integer,
    interaction_type text,
    data text,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.interaction_memory OWNER TO oscar;

--
-- Name: interaction_memory_interaction_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.interaction_memory_interaction_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.interaction_memory_interaction_id_seq OWNER TO oscar;

--
-- Name: interaction_memory_interaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.interaction_memory_interaction_id_seq OWNED BY public.interaction_memory.interaction_id;


--
-- Name: isaac_sim_gui; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.isaac_sim_gui (
    sequence_id integer NOT NULL,
    gui_feature text NOT NULL,
    operation_status boolean DEFAULT false
);


ALTER TABLE public.isaac_sim_gui OWNER TO oscar;

--
-- Name: isaac_sim_gui_sequence_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.isaac_sim_gui_sequence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.isaac_sim_gui_sequence_id_seq OWNER TO oscar;

--
-- Name: isaac_sim_gui_sequence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.isaac_sim_gui_sequence_id_seq OWNED BY public.isaac_sim_gui.sequence_id;


--
-- Name: lift_state_parameters; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.lift_state_parameters (
    sequence_id integer NOT NULL,
    operation_order integer NOT NULL,
    object_id text NOT NULL,
    lift_height double precision NOT NULL,
    operation_status boolean NOT NULL
);


ALTER TABLE public.lift_state_parameters OWNER TO oscar;

--
-- Name: lift_state_parameters_sequence_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.lift_state_parameters_sequence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lift_state_parameters_sequence_id_seq OWNER TO oscar;

--
-- Name: lift_state_parameters_sequence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.lift_state_parameters_sequence_id_seq OWNED BY public.lift_state_parameters.sequence_id;


--
-- Name: operation_library; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.operation_library (
    id integer NOT NULL,
    operation_name text NOT NULL,
    task_order text,
    description text,
    trigger_keywords text[],
    script_path text,
    is_triggerable boolean DEFAULT true,
    trigger boolean DEFAULT false,
    state text DEFAULT 'idle'::text,
    last_triggered timestamp without time zone
);


ALTER TABLE public.operation_library OWNER TO oscar;

--
-- Name: operation_library_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.operation_library_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.operation_library_id_seq OWNER TO oscar;

--
-- Name: operation_library_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.operation_library_id_seq OWNED BY public.operation_library.id;


--
-- Name: operation_sequence; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.operation_sequence (
    id integer NOT NULL,
    operation_id integer NOT NULL,
    sequence_id integer NOT NULL,
    sequence_name text NOT NULL,
    object_name text,
    command_id integer,
    processed boolean DEFAULT false,
    execution_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.operation_sequence OWNER TO oscar;

--
-- Name: operation_sequence_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.operation_sequence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.operation_sequence_id_seq OWNER TO oscar;

--
-- Name: operation_sequence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.operation_sequence_id_seq OWNED BY public.operation_sequence.id;


--
-- Name: pick_op_parameters; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.pick_op_parameters (
    sequence_id integer NOT NULL,
    operation_order integer NOT NULL,
    object_id text NOT NULL,
    slide_state_status boolean NOT NULL,
    slide_direction text NOT NULL,
    distance_travel double precision NOT NULL,
    operation_status boolean NOT NULL
);


ALTER TABLE public.pick_op_parameters OWNER TO oscar;

--
-- Name: pick_op_parameters_sequence_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.pick_op_parameters_sequence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pick_op_parameters_sequence_id_seq OWNER TO oscar;

--
-- Name: pick_op_parameters_sequence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.pick_op_parameters_sequence_id_seq OWNED BY public.pick_op_parameters.sequence_id;


--
-- Name: rotate_state_parameters; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.rotate_state_parameters (
    sequence_id integer NOT NULL,
    operation_order integer NOT NULL,
    object_id text NOT NULL,
    rotation_angle double precision NOT NULL,
    operation_status boolean NOT NULL
);


ALTER TABLE public.rotate_state_parameters OWNER TO oscar;

--
-- Name: rotate_state_parameters_sequence_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.rotate_state_parameters_sequence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rotate_state_parameters_sequence_id_seq OWNER TO oscar;

--
-- Name: rotate_state_parameters_sequence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.rotate_state_parameters_sequence_id_seq OWNED BY public.rotate_state_parameters.sequence_id;


--
-- Name: screw_op_parameters; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.screw_op_parameters (
    sequence_id integer NOT NULL,
    operation_order integer NOT NULL,
    object_id text NOT NULL,
    rotation_dir boolean NOT NULL,
    number_of_rotations integer NOT NULL,
    current_rotation integer NOT NULL,
    operation_status boolean NOT NULL
);


ALTER TABLE public.screw_op_parameters OWNER TO oscar;

--
-- Name: screw_op_parameters_sequence_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.screw_op_parameters_sequence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.screw_op_parameters_sequence_id_seq OWNER TO oscar;

--
-- Name: screw_op_parameters_sequence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.screw_op_parameters_sequence_id_seq OWNED BY public.screw_op_parameters.sequence_id;


--
-- Name: sequence_library; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.sequence_library (
    sequence_id integer NOT NULL,
    sequence_name text NOT NULL,
    skill_name text,
    node_name text,
    description text,
    conditions text,
    post_conditions text,
    is_runnable_count integer,
    is_runnable_condition text,
    is_runnable_exit boolean
);


ALTER TABLE public.sequence_library OWNER TO oscar;

--
-- Name: sequence_library_sequence_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.sequence_library_sequence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sequence_library_sequence_id_seq OWNER TO oscar;

--
-- Name: sequence_library_sequence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.sequence_library_sequence_id_seq OWNED BY public.sequence_library.sequence_id;


--
-- Name: simulation_results; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.simulation_results (
    simulation_id integer NOT NULL,
    instruction_id integer,
    success boolean,
    metrics text,
    error_log text,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.simulation_results OWNER TO oscar;

--
-- Name: simulation_results_simulation_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.simulation_results_simulation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.simulation_results_simulation_id_seq OWNER TO oscar;

--
-- Name: simulation_results_simulation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.simulation_results_simulation_id_seq OWNED BY public.simulation_results.simulation_id;


--
-- Name: skills; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.skills (
    skill_id integer NOT NULL,
    skill_name text NOT NULL,
    description text,
    parameters text,
    required_capabilities text,
    average_duration real
);


ALTER TABLE public.skills OWNER TO oscar;

--
-- Name: skills_skill_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.skills_skill_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.skills_skill_id_seq OWNER TO oscar;

--
-- Name: skills_skill_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.skills_skill_id_seq OWNED BY public.skills.skill_id;


--
-- Name: slide_state_parameters; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.slide_state_parameters (
    sequence_id integer NOT NULL,
    operation_order integer NOT NULL,
    object_id text NOT NULL,
    lift_distance double precision NOT NULL,
    pos_x double precision NOT NULL,
    pos_y double precision NOT NULL,
    pos_z double precision NOT NULL,
    operation_status boolean NOT NULL
);


ALTER TABLE public.slide_state_parameters OWNER TO oscar;

--
-- Name: slide_state_parameters_sequence_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.slide_state_parameters_sequence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.slide_state_parameters_sequence_id_seq OWNER TO oscar;

--
-- Name: slide_state_parameters_sequence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.slide_state_parameters_sequence_id_seq OWNED BY public.slide_state_parameters.sequence_id;


--
-- Name: sort_order; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.sort_order (
    order_id integer NOT NULL,
    object_name text,
    object_color text
);


ALTER TABLE public.sort_order OWNER TO oscar;

--
-- Name: sort_order_order_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.sort_order_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sort_order_order_id_seq OWNER TO oscar;

--
-- Name: sort_order_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.sort_order_order_id_seq OWNED BY public.sort_order.order_id;


--
-- Name: states; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.states (
    task_id integer NOT NULL,
    task_name text NOT NULL,
    description text,
    conditions text,
    post_conditions text,
    sequence_id integer
);


ALTER TABLE public.states OWNER TO oscar;

--
-- Name: states_task_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.states_task_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.states_task_id_seq OWNER TO oscar;

--
-- Name: states_task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.states_task_id_seq OWNED BY public.states.task_id;


--
-- Name: task_history; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.task_history (
    id integer NOT NULL,
    command_text text,
    generated_plan jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.task_history OWNER TO oscar;

--
-- Name: task_history_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.task_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_history_id_seq OWNER TO oscar;

--
-- Name: task_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.task_history_id_seq OWNED BY public.task_history.id;


--
-- Name: task_preferences; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.task_preferences (
    preference_id integer NOT NULL,
    user_id integer,
    task_id text,
    task_name text,
    preference_data text
);


ALTER TABLE public.task_preferences OWNER TO oscar;

--
-- Name: task_preferences_preference_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.task_preferences_preference_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_preferences_preference_id_seq OWNER TO oscar;

--
-- Name: task_preferences_preference_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.task_preferences_preference_id_seq OWNED BY public.task_preferences.preference_id;


--
-- Name: task_templates; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.task_templates (
    task_id integer NOT NULL,
    task_name text NOT NULL,
    description text,
    default_sequence text[]
);


ALTER TABLE public.task_templates OWNER TO oscar;

--
-- Name: task_templates_task_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.task_templates_task_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_templates_task_id_seq OWNER TO oscar;

--
-- Name: task_templates_task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.task_templates_task_id_seq OWNED BY public.task_templates.task_id;


--
-- Name: travel_op_parameters; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.travel_op_parameters (
    sequence_id integer NOT NULL,
    operation_order integer NOT NULL,
    object_id text NOT NULL,
    travel_height double precision NOT NULL,
    gripper_rotation text NOT NULL,
    operation_status boolean NOT NULL
);


ALTER TABLE public.travel_op_parameters OWNER TO oscar;

--
-- Name: travel_op_parameters_sequence_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.travel_op_parameters_sequence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.travel_op_parameters_sequence_id_seq OWNER TO oscar;

--
-- Name: travel_op_parameters_sequence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.travel_op_parameters_sequence_id_seq OWNED BY public.travel_op_parameters.sequence_id;


--
-- Name: unified_instructions; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.unified_instructions (
    id integer NOT NULL,
    session_id text,
    "timestamp" timestamp without time zone,
    liu_id text,
    voice_command text,
    gesture_command text,
    unified_command text,
    confidence double precision,
    processed boolean DEFAULT false,
    CONSTRAINT unified_instructions_confidence_check CHECK (((confidence >= (0)::double precision) AND (confidence <= (1)::double precision)))
);


ALTER TABLE public.unified_instructions OWNER TO oscar;

--
-- Name: unified_instructions_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

ALTER TABLE public.unified_instructions ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.unified_instructions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: usd_data; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.usd_data (
    sequence_id integer NOT NULL,
    usd_name text NOT NULL,
    type_of_usd text NOT NULL,
    repository text NOT NULL,
    block_height double precision NOT NULL,
    block_pick_height double precision NOT NULL,
    scale_x double precision NOT NULL,
    scale_y double precision NOT NULL,
    scale_z double precision NOT NULL,
    prim_path text NOT NULL,
    initial_pos_x double precision NOT NULL,
    initial_pos_y double precision NOT NULL,
    initial_pos_z double precision NOT NULL,
    register_obstacle boolean NOT NULL
);


ALTER TABLE public.usd_data OWNER TO oscar;

--
-- Name: users; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    liu_id text,
    email text,
    preferences text,
    profile_image_path text,
    interaction_memory text,
    face_encoding bytea,
    voice_embedding bytea,
    role text DEFAULT 'guest'::text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT users_role_check CHECK ((role = ANY (ARRAY['robot'::text, 'team'::text, 'guest'::text, 'admin'::text])))
);


ALTER TABLE public.users OWNER TO oscar;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO oscar;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: voice_instructions; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.voice_instructions (
    id integer NOT NULL,
    session_id text NOT NULL,
    transcribed_text text NOT NULL,
    confidence real,
    language text NOT NULL,
    processed boolean DEFAULT false,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.voice_instructions OWNER TO oscar;

--
-- Name: voice_instructions_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

ALTER TABLE public.voice_instructions ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.voice_instructions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: camera_vision object_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.camera_vision ALTER COLUMN object_id SET DEFAULT nextval('public.camera_vision_object_id_seq'::regclass);


--
-- Name: drop_op_parameters sequence_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.drop_op_parameters ALTER COLUMN sequence_id SET DEFAULT nextval('public.drop_op_parameters_sequence_id_seq'::regclass);


--
-- Name: instruction_operation_sequence task_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.instruction_operation_sequence ALTER COLUMN task_id SET DEFAULT nextval('public.instruction_operation_sequence_task_id_seq'::regclass);


--
-- Name: interaction_memory interaction_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.interaction_memory ALTER COLUMN interaction_id SET DEFAULT nextval('public.interaction_memory_interaction_id_seq'::regclass);


--
-- Name: isaac_sim_gui sequence_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.isaac_sim_gui ALTER COLUMN sequence_id SET DEFAULT nextval('public.isaac_sim_gui_sequence_id_seq'::regclass);


--
-- Name: lift_state_parameters sequence_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.lift_state_parameters ALTER COLUMN sequence_id SET DEFAULT nextval('public.lift_state_parameters_sequence_id_seq'::regclass);


--
-- Name: operation_library id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.operation_library ALTER COLUMN id SET DEFAULT nextval('public.operation_library_id_seq'::regclass);


--
-- Name: operation_sequence id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.operation_sequence ALTER COLUMN id SET DEFAULT nextval('public.operation_sequence_id_seq'::regclass);


--
-- Name: pick_op_parameters sequence_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.pick_op_parameters ALTER COLUMN sequence_id SET DEFAULT nextval('public.pick_op_parameters_sequence_id_seq'::regclass);


--
-- Name: rotate_state_parameters sequence_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.rotate_state_parameters ALTER COLUMN sequence_id SET DEFAULT nextval('public.rotate_state_parameters_sequence_id_seq'::regclass);


--
-- Name: screw_op_parameters sequence_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.screw_op_parameters ALTER COLUMN sequence_id SET DEFAULT nextval('public.screw_op_parameters_sequence_id_seq'::regclass);


--
-- Name: sequence_library sequence_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.sequence_library ALTER COLUMN sequence_id SET DEFAULT nextval('public.sequence_library_sequence_id_seq'::regclass);


--
-- Name: simulation_results simulation_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.simulation_results ALTER COLUMN simulation_id SET DEFAULT nextval('public.simulation_results_simulation_id_seq'::regclass);


--
-- Name: skills skill_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.skills ALTER COLUMN skill_id SET DEFAULT nextval('public.skills_skill_id_seq'::regclass);


--
-- Name: slide_state_parameters sequence_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.slide_state_parameters ALTER COLUMN sequence_id SET DEFAULT nextval('public.slide_state_parameters_sequence_id_seq'::regclass);


--
-- Name: sort_order order_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.sort_order ALTER COLUMN order_id SET DEFAULT nextval('public.sort_order_order_id_seq'::regclass);


--
-- Name: states task_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.states ALTER COLUMN task_id SET DEFAULT nextval('public.states_task_id_seq'::regclass);


--
-- Name: task_history id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.task_history ALTER COLUMN id SET DEFAULT nextval('public.task_history_id_seq'::regclass);


--
-- Name: task_preferences preference_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.task_preferences ALTER COLUMN preference_id SET DEFAULT nextval('public.task_preferences_preference_id_seq'::regclass);


--
-- Name: task_templates task_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.task_templates ALTER COLUMN task_id SET DEFAULT nextval('public.task_templates_task_id_seq'::regclass);


--
-- Name: travel_op_parameters sequence_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.travel_op_parameters ALTER COLUMN sequence_id SET DEFAULT nextval('public.travel_op_parameters_sequence_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Data for Name: access_logs; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.access_logs (log_id, user_id, action_type, target_table, "timestamp") FROM stdin;
\.


--
-- Data for Name: camera_vision; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.camera_vision (object_id, object_name, object_color, color_code, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, usd_name, last_detected) FROM stdin;
\.


--
-- Data for Name: drop_op_parameters; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.drop_op_parameters (sequence_id, operation_order, object_id, drop_height, drop_pos_x, drop_pos_y, drop_pos_z, operation_status) FROM stdin;
\.


--
-- Data for Name: gesture_instructions; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.gesture_instructions (id, session_id, "timestamp", gesture_text, natural_description, confidence, hand_label, processed) FROM stdin;
\.


--
-- Data for Name: gesture_library; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.gesture_library (id, gesture_type, gesture_text, natural_description, config) FROM stdin;
1	thumbs_up	Approval	The thumb is raised above the index finger.	{"threshold": 0.0}
2	open_hand	Stop	All fingers are extended, signaling stop.	{"threshold": 0.0}
3	pointing	Select Object	The index finger is extended while other fingers are curled.	{"threshold": 0.0}
4	closed_fist	Grab	The hand is clenched into a fist.	{"threshold": 0.0}
5	victory	Confirm	The hand forms a V-shape with the index and middle fingers extended.	{"threshold": 0.0}
6	ok_sign	OK	The thumb and index finger are touching to form a circle.	{"threshold": 0.05}
\.


--
-- Data for Name: instruction_operation_sequence; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.instruction_operation_sequence (task_id, instruction_id, skill_id, skill_name, sequence_id, sequence_name, object_id, object_name, status, created_at) FROM stdin;
\.


--
-- Data for Name: instructions; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.instructions (id, "timestamp", user_id, modality, language, instruction_type, processed, content, sync_id, confidence) FROM stdin;
1	2025-05-28 08:44:48.370597	1	voice	en	command	f	Pick up object	\N	0.95
2	2025-05-28 08:44:48.370597	2	text	en	command	f	Place object	\N	0.9
\.


--
-- Data for Name: interaction_memory; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.interaction_memory (interaction_id, user_id, instruction_id, interaction_type, data, start_time, end_time, "timestamp") FROM stdin;
1	1	1	task_query	{"task": "Pick Object"}	2023-10-01 09:00:00	2023-10-01 17:00:00	2025-05-28 08:44:48.370597
2	2	1	preference_update	{"preference": {"time": "morning"}}	2023-10-01 09:00:00	2023-10-01 17:00:00	2025-05-28 08:44:48.370597
3	1	2	task_execution	{"status": "success", "task": "Place Object"}	2023-10-02 09:00:00	2023-10-02 17:00:00	2025-05-28 08:44:48.370597
\.


--
-- Data for Name: isaac_sim_gui; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.isaac_sim_gui (sequence_id, gui_feature, operation_status) FROM stdin;
1	Start	f
2	Reset	f
3	Load	f
\.


--
-- Data for Name: lift_state_parameters; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.lift_state_parameters (sequence_id, operation_order, object_id, lift_height, operation_status) FROM stdin;
\.


--
-- Data for Name: operation_library; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.operation_library (id, operation_name, task_order, description, trigger_keywords, script_path, is_triggerable, trigger, state, last_triggered) FROM stdin;
1	slide_sorting	pick, travel, drop	Sort slides by shape and color into trays	{sort,slides,slide,sorting,tray,"sort slides"}	detect_slides_pgSQL.py	t	f	idle	\N
2	shape_stacking	pick, travel, drop	Stack blocks of shapes based on their type and color	{stack,stacking,shapes,shape,"blocksshape stacking"}	detect_shapes_pgSQL.py	t	f	idle	\N
\.


--
-- Data for Name: operation_sequence; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.operation_sequence (id, operation_id, sequence_id, sequence_name, object_name, command_id, processed, execution_time) FROM stdin;
\.


--
-- Data for Name: pick_op_parameters; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.pick_op_parameters (sequence_id, operation_order, object_id, slide_state_status, slide_direction, distance_travel, operation_status) FROM stdin;
\.


--
-- Data for Name: rotate_state_parameters; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.rotate_state_parameters (sequence_id, operation_order, object_id, rotation_angle, operation_status) FROM stdin;
\.


--
-- Data for Name: screw_op_parameters; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.screw_op_parameters (sequence_id, operation_order, object_id, rotation_dir, number_of_rotations, current_rotation, operation_status) FROM stdin;
\.


--
-- Data for Name: sequence_library; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.sequence_library (sequence_id, sequence_name, skill_name, node_name, description, conditions, post_conditions, is_runnable_count, is_runnable_condition, is_runnable_exit) FROM stdin;
1	pick	\N	PickBlockRd	Pick up an object	gripper is clear	object in gripper	1	aaa	f
2	travel	\N	ReachToPlacementRd	Move to the target location	object in gripper	at target location	1	aaa	f
3	drop	\N	DropRd	Drop the object	at target location	object dropped	1	aaa	f
4	screw	\N	ScrewRd	Screw the object two times	task complete	robot at home position	1	thresh_met and self.context.gripper_has_block	t
5	rotate	\N	RotateRd	Rotate the object once	task complete	robot at home position	1	thresh_met and self.context.gripper_has_block	t
6	go_home	\N	GoHome	Return to the home position	task complete	robot at home position	1	aaa	f
\.


--
-- Data for Name: simulation_results; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.simulation_results (simulation_id, instruction_id, success, metrics, error_log, "timestamp") FROM stdin;
1	1	t	{"accuracy": 0.95, "time_taken": 2.5}	No errors	2025-05-28 08:44:48.370597
2	2	f	{"accuracy": 0.8, "time_taken": 3.0}	Gripper misalignment	2025-05-28 08:44:48.370597
\.


--
-- Data for Name: skills; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.skills (skill_id, skill_name, description, parameters, required_capabilities, average_duration) FROM stdin;
1	pick	Pick up object	{"gripper_force": 0.5}	{"gripper": true}	2.5
2	place	Place object	{"precision": 0.01}	{"vision": true}	3
\.


--
-- Data for Name: slide_state_parameters; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.slide_state_parameters (sequence_id, operation_order, object_id, lift_distance, pos_x, pos_y, pos_z, operation_status) FROM stdin;
\.


--
-- Data for Name: sort_order; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.sort_order (order_id, object_name, object_color) FROM stdin;
\.


--
-- Data for Name: states; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.states (task_id, task_name, description, conditions, post_conditions, sequence_id) FROM stdin;
1	LiftState	Lift an object vertically	gripper is clear	object in gripper	1
2	SlideState	Slide an object along X-axis	object in gripper	at target location	1
\.


--
-- Data for Name: task_history; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.task_history (id, command_text, generated_plan, created_at) FROM stdin;
\.


--
-- Data for Name: task_preferences; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.task_preferences (preference_id, user_id, task_id, task_name, preference_data) FROM stdin;
1	1	\N	Pick Object	{"time": "morning", "location": "shelf"}
2	2	\N	Place Object	{"time": "afternoon", "location": "table"}
3	1	\N	Inspect Object	{"tools": ["camera", "gripper"]}
\.


--
-- Data for Name: task_templates; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.task_templates (task_id, task_name, description, default_sequence) FROM stdin;
1	sort	Default sorting task: pick, move, drop	{pick,travel,drop}
2	assemble	Assembly involves pick and screw	{pick,travel,screw,go_home}
3	inspect	Inspect task involves scan and return	{travel,inspect,go_home}
4	cleanup	Cleanup task involves pick, rotate, drop	{pick,rotate,drop}
\.


--
-- Data for Name: travel_op_parameters; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.travel_op_parameters (sequence_id, operation_order, object_id, travel_height, gripper_rotation, operation_status) FROM stdin;
\.


--
-- Data for Name: unified_instructions; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.unified_instructions (id, session_id, "timestamp", liu_id, voice_command, gesture_command, unified_command, confidence, processed) FROM stdin;
\.


--
-- Data for Name: usd_data; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.usd_data (sequence_id, usd_name, type_of_usd, repository, block_height, block_pick_height, scale_x, scale_y, scale_z, prim_path, initial_pos_x, initial_pos_y, initial_pos_z, register_obstacle) FROM stdin;
1	Fixture.usd	GeometryPrim	/fixture_description/Slide_Fixture.usd	0	0	0.1	0.1	0.1	/World/fixtureprim	0.2	-0.07	0.094	f
2	Slide_Holder.usd	GeometryPrim	/fixture_description/Slide_Holder.usd	0	0	0.1	0.1	0.1	/World/fixtureprim	40	17	8	f
3	Slide.usd	RigidPrim	/fixture_description/Slide1.usd	0.002	0.016	1	1	0.06	/World/fixtureprim/Fixture	0	0	0	t
4	Cuboid.usd	RigidPrim	/yumi_basic_shapes/cuboid.usd	0.025	0.015	0.1	0.11	0.1	/World/fixtureprim	0.55475	-0.116	0.113	t
5	Cylinder.usd	RigidPrim	/yumi_basic_shapes/cylinder.usd	0.025	0.015	0.1	0.1	0.1	/World/fixtureprim	0.41475	-0.116	0.113	t
6	Cube.usd	RigidPrim	/yumi_basic_shapes/cube.usd	0.025	0.015	0.1	0.1	0.1	/World/fixtureprim	0.34475	-0.116	0.113	t
7	Hexagon.usd	RigidPrim	/yumi_basic_shapes/hexagon.usd	0.025	0.015	0.1	0.1	0.1	/World/fixtureprim	0.48475	-0.116	0.113	t
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.users (user_id, first_name, last_name, liu_id, email, preferences, profile_image_path, interaction_memory, face_encoding, voice_embedding, role, created_at, last_updated) FROM stdin;
1	Yumi	Robot	yumi100	yumi100@lab.liu.ai	{"likes": ["AI", "Robotics"]}	/images/yumi001.jpg	{"last_task": "Assistance", "successful_tasks": 100}	\N	\N	robot	2025-05-28 08:44:48.370597	2025-05-28 08:44:48.394059
6	Marie	Jonsson	marjo33	marie.s.jonsson@liu.se	{"likes": ["Robots", "Composites"]}	/images/marjo33.jpg	{"last_task": "Fix robot battery", "successful_tasks": 2}	\N	\N	team	2025-05-28 08:44:48.370597	2025-05-28 08:44:48.394059
4	Sanjay	Nambiar	sanna58	sanjay.nambiar@liu.se	{"likes": ["Programming", "Machine Learning"]}	/images/sanna58.jpg	{"last_task": "Slide object", "successful_tasks": 7}	\N	\N	admin	2025-05-28 08:44:48.370597	2025-05-28 08:44:48.394059
7	Aref	Aghaee	areag806	areag806@student.liu.se	{"likes": ["CATIA", "Turbine Blades"]}	/images/areag806.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\N	\N	guest	2025-05-28 08:44:48.370597	2025-05-28 08:44:48.394059
8	Thomson	Kalliyath	thoka981	thoka981@student.liu.se	{"likes": ["Omniverse", "Aeronautics"]}	/images/thoka981.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\N	\N	guest	2025-05-28 08:44:48.370597	2025-05-28 08:44:48.394059
9	Hamideh	Pourrasoul	hampo845	hampo845@student.liu.se	{"likes": ["CATIA", "Turbine Blades"]}	/images/hampo845.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\N	\N	guest	2025-05-28 08:44:48.370597	2025-05-28 08:44:48.394059
10	John	Ashish	johas759	johas759@student.liu.se	{"likes": ["python", "aircraft wings"]}	/images/johas759.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\N	\N	guest	2025-05-28 08:44:48.370597	2025-05-28 08:44:48.394059
11	Danial	Nikpey	danni741	danni741@student.liu.se	{"likes": ["vb.net", "aircraft wings"]}	/images/danni741.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\N	\N	guest	2025-05-28 08:44:48.370597	2025-05-28 08:44:48.394059
5	Mehdi	Tarkian	mehta77	mehdi.tarkian@liu.se	{"likes": ["Running", "Cats"]}	/images/mehta77.jpg	{"last_task": "Drop object", "successful_tasks": 2}	\N	\N	team	2025-05-28 08:44:48.370597	2025-05-28 08:44:48.394059
2	Oscar	Ikechukwu	oscik559	oscik559@student.liu.se	{"likes": ["AI", "Robotics"]}	/images/oscik559.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\\x8004959b150000000000005d94288c156e756d70792e636f72652e6d756c74696172726179948c0c5f7265636f6e7374727563749493948c056e756d7079948c076e6461727261799493944b0085944301629487945294284b014b80859468048c0564747970659493948c02663894898887945294284b038c013c944e4e4e4affffffff4affffffff4b00749462894200040000000000805b4cc2bf0000000099f6be3f000000e0cfa0c53f00000000b7e595bf000000809cdf893f000000c0df76b9bf00000020a45fac3f000000e0ea53a3bf00000060a1f6c03f000000a00cd0aebf00000040a20dd13f000000c055636ebf000000a01bb5c6bf00000020084ac2bf00000000905e9a3f00000060afaec23f000000c056aec5bf00000080e5f0b7bf0000004092c9a9bf000000e0bf45c3bf000000a05d66ac3f000000a0512eae3f000000e095e0abbf00000000773aa63f00000080d964a8bf000000c0fafacfbf00000040388ebbbf000000803464c1bf000000601768bb3f000000e0e4f0bcbf000000e03cb8963f00000080d7ea98bf000000e0e010c1bf000000400dc1a0bf000000e0c276b4bf00000080bf48803f000000801bbb903f000000807548b6bf000000c0ad55ba3f000000c06f8db23f000000807b11afbf0000008020caafbf000000401442afbf00000000b071d23f00000080f650c43f000000a0d998aabf000000c0cb09903f00000000c95e713f000000a02432b03f000000406c92cebf000000402c4985bf00000000c940b83f000000404d38c03f0000008078deba3f000000a06b4d963f000000c044d8b9bf000000a0f5bda6bf00000000a8b2313f000000000677cbbf0000004014dca93f00000040efada13f00000080589ebdbf00000020951bbebf000000609367b0bf00000040eda3cb3f00000020a7fbbe3f00000080adacbdbf00000040949dc3bf000000407377c73f000000e0bcf3c0bf000000004ec4a8bf000000e08214b23f000000200b93b6bf0000004011b9abbf000000c045b9c9bf0000008016b3c33f00000020e1f9d33f000000207c41ba3f00000080ce69c5bf000000e02add8bbf000000c0b71bd0bf000000c02919a03f000000c074b9a4bf00000000d3f170bf0000008049a8a8bf0000004032ceab3f00000080f4d1bebf00000040004f9f3f000000a09b19b13f000000e04986b2bf00000020a9068ebf000000c02c3bcc3f00000020bf3699bf000000401412a13f000000e0f4ce853f0000006037a381bf000000c06705adbf000000000ecd4f3f000000c09e4da2bf00000020e86fabbf000000a00d89bc3f000000c028e5babf000000404e68a23f0000006002c5ab3f00000040994cc0bf000000002b31c53f000000c0c463a13f000000005091663f000000806200983f000000208a28993f0000006052a6c0bf000000a00f62a7bf0000008030c0c53f000000c08dfbc7bf00000000c417c93f000000e0457dc43f00000080669c803f000000609f17be3f0000000066ef983f0000002065cdbf3f00000020eaa3babf000000c00386babf00000080e5fca4bf000000a0542298bf000000c06282a03f00000000bf91913f000000005886a5bf0000000055548a3f94749462680368064b008594680887945294284b014b808594680d8c02663894898887945294284b0368114e4e4e4affffffff4affffffff4b00749462894200040000000000a0d357c6bf000000c09290bb3f000000408b0ec73f000000a01ab287bf000000408b50a43f000000009f49b6bf00000040da0db13f000000000047aebf000000e0c565bd3f00000080485badbf0000002083a3d03f000000802e6a86bf000000000e99c7bf000000c0dfa0c1bf000000c0e48ca33f000000802b30c13f000000005f75c3bf00000080c6d6b9bf000000000eb6b2bf000000e0822fbebf000000a00e78a63f000000a0d7b8aa3f000000a08a88b1bf000000404b5aa03f000000a0f320a6bf000000808b0ed0bf00000080acf9b5bf000000806388babf00000060c980be3f00000060bb4ebcbf00000000c55366bf00000000faeeb0bf00000040ff46c4bf00000000b0e9783f000000a0be61bbbf00000020bfd6a73f00000040650da13f00000080ced7babf0000002051e2b93f000000c0c9beb63f00000020c7c3b5bf0000008037a0b6bf00000040d184b0bf0000008066dad13f000000e0d251c63f000000005808b0bf000000005ffc88bf000000e0aaea8b3f00000080b362b43f00000020ca33d1bf000000c0be4586bf00000040eb04b63f000000e08cc5c23f000000200b42b73f000000805c66913f00000020223ebbbf000000c0830ea4bf000000001f1569bf0000004082b6cebf000000c03be9a83f000000403b9b993f000000a0e417bdbf000000c07225babf000000a0514aadbf000000206d6fc93f000000e0a951c13f000000a05f25bebf000000a09885bcbf000000a0ee89c83f000000a08663c0bf000000001fdd9cbf00000040b61ea33f000000c0a251b1bf00000000223bb4bf00000020d86fcdbf000000a0bf88c23f00000000c017d53f0000002074a5ba3f00000020df4ec6bf00000080de4a8bbf000000004f00d0bf0000008008a1863f000000a038c395bf000000c0b5c190bf00000040a556a8bf000000409d40ac3f000000e0aac5c1bf00000020582ea93f000000c06cf6b83f000000c0353bafbf000000c09dcb813f00000080dae7c93f00000040ab50a2bf000000e063818e3f00000000040285bf000000a0c7ea8d3f000000c0b87ca7bf00000040d3d9883f000000207d9ba0bf000000001b92a2bf000000c0bbfab93f000000605a73bebf000000a05325ad3f000000c08c3eab3f00000040d7b0c4bf000000a092e4c53f00000060e73bb53f000000c0b04992bf00000000cdb5a83f000000008ecc423f000000208042c0bf000000e0713b9ebf000000808a05c43f00000060b645c9bf000000002585ca3f00000040c56dc53f0000000098d9713f000000002622c03f000000204b4b803f000000c08b95bd3f000000e00ed0b5bf00000080980bb8bf00000020be01a4bf000000a06ceca3bf0000000070885f3f000000a023ee953f000000001de6a2bf00000040d540a93f94749462680368064b008594680887945294284b014b808594680d8c02663894898887945294284b0368114e4e4e4affffffff4affffffff4b00749462894200040000000000a05238c5bf000000a06285c03f00000080b579c53f000000e0f6d394bf0000004093ea8d3f00000000931fbcbf000000c056a5b73f00000040f0b18fbf000000a0d204c03f000000202cd6aabf000000406787d23f000000c0565980bf000000c07599c6bf000000c07c8dbebf000000606094aa3f000000405375c33f000000402165c4bf000000a0c71bc1bf000000e04c20b8bf000000a0be72bfbf000000c0bfe5a33f000000008646a43f000000608454b7bf000000808209b43f000000c02fb7abbf000000402c03ccbf0000008074c5b4bf00000080dcf9bdbf000000a000a8b63f0000008066a6bcbf000000c0b093983f00000020b21979bf0000000057a0c0bf00000080158d9ebf00000060787ea9bf000000606eeb993f000000e09c4baa3f00000040768eb4bf00000060ea0fc63f000000a07ba9b03f000000a09faebdbf000000a03979b6bf00000080516399bf00000060369dd53f0000002093fcc23f000000c0c768b4bf00000080e274743f000000008ff3ab3f000000205d48b23f0000006087c2cebf000000000011293f00000040ef4cbb3f00000020ae2fc63f000000001e75b93f000000005c4d80bf00000000b22eb7bf000000c01f7498bf0000004073cd9c3f00000040b8c0ccbf000000205b2ba93f000000205e4cb43f00000060dadfc6bf000000400a8bbebf000000007d81b1bf00000060d78acb3f000000000376bd3f000000e05b71bebf000000c037edc4bf000000c0c977c83f0000004083f9bfbf00000000002cb3bf000000805ddab43f000000206846bbbf000000c086dda4bf00000000e5a2ccbf000000806016c13f00000040ed24d53f00000000e8ceb53f000000a0469ac6bf0000002079a390bf00000000b6c6ccbf000000e0507f823f000000c03e71a5bf000000809124743f00000040facfabbf000000a0d47fae3f00000080c78ac0bf000000807acbab3f000000c06887c13f000000c0adf89bbf00000020d9c682bf00000060df8dc73f00000000891880bf000000c0ed5d9dbf000000a0ac9b703f000000c05fae8fbf00000040bf6d823f0000004043ee8bbf00000020a85ea8bf00000000c7246abf000000002600b43f00000000d17ebfbf00000080e8e2933f000000803bb4ad3f00000060e909c8bf000000604036c33f000000404bbea93f000000009cd134bf00000040e8b365bf000000802494a13f000000202d46c1bf00000080c6a5a0bf000000a03271c63f000000005dfbc6bf00000000594fc73f000000c048f7c43f000000202564a13f000000c098f6b13f000000c0af4a7b3f000000607bc1b83f000000602101b4bf00000040f12ebbbf00000000be59b2bf000000a046bcaabf000000803a45a93f0000000030ee493f000000a082678d3f00000080546ea23f94749462680368064b008594680887945294284b014b808594680d8c02663894898887945294284b0368114e4e4e4affffffff4affffffff4b007494628942000400000000000012bec0bf00000080f7c89c3f000000205f6fba3f00000040336991bf00000000653aa23f000000e06545c0bf00000060b0abb33f000000c0b850b2bf000000403c33c13f000000c06b2fa03f00000060c4dbce3f00000000213c73bf000000a0ca2dc6bf000000402265c9bf000000006f5cb03f0000006046f2b73f0000000050e4c5bf000000207bb4b3bf00000020140ab7bf00000040f37bc0bf000000006b57703f000000009606b33f000000205002a43f00000020cf1db33f0000006037f9b7bf000000603d49cdbf000000201e20bcbf000000002682cdbf00000080fb52bd3f00000000cc66b9bf00000000cfa565bf00000000fd84a93f00000080e751c5bf00000000bb67bebf00000040e0aa803f00000060b3a1a13f000000400a63aa3f000000c0b8bfadbf00000020b776c33f000000a0707f8f3f000000401ed3bcbf00000040dc5fbbbf000000e0fc8b8f3f000000e0b61fd03f0000002001ffc13f00000020d501b3bf000000807c66943f00000000b5d4a83f000000809c53be3f000000c002e2ccbf000000803ad4a13f000000e0f65fb03f000000c0b089c83f000000009798aa3f000000c03beeb73f000000e0dd13c5bf000000403614743f0000006093f7983f000000606412cabf00000060a1ceb23f00000040cae3863f00000040035eb2bf000000c0ebf7babf00000060385ba83f000000201bb1c13f000000000752bd3f000000a09b77acbf00000000f8becabf00000040e9e8c73f000000a014e0c2bf000000e0ca9e96bf000000a067e3c43f000000e032efbcbf000000c0c525b3bf0000006066bacfbf000000c09ab5ac3f000000e0f7eed43f00000000f83d9c3f000000a03c09cdbf0000008057df923f00000000f947cabf0000004091f3863f00000040d3ce6b3f000000e06df960bf000000c09904a8bf00000080393abe3f000000207fedc4bf000000803e1584bf00000000b69eb83f00000000c639b0bf0000008000b997bf00000020f175c83f000000009cbc52bf000000004a98a13f00000080cd33b53f000000c02b1a7bbf000000406dc594bf00000000193a86bf000000600f45b5bf000000c0b1a57abf000000005df8c03f000000e07912b3bf00000000deb280bf00000020614aad3f000000203072c3bf00000080b77ebd3f00000020a428aa3f00000080d54ea0bf000000c033149dbf000000804f8880bf00000040c6cab7bf00000000fcd1a4bf000000405201c53f00000000f918cdbf000000c090f4c73f000000e04142c33f00000040974fafbf00000020b76cb83f000000207894a7bf000000601e3fb03f000000c0f0e7adbf000000e0cad6adbf00000000b7edb0bf000000205f5dadbf000000601451a53f000000608fdba0bf00000080767bb7bf000000405b2a80bf94749462680368064b008594680887945294284b014b808594680d8c02663894898887945294284b0368114e4e4e4affffffff4affffffff4b007494628942000400000000008088ffc1bf0000008049c5b43f000000002b31c53f0000008042ee8fbf00000040730ea73f000000e03652c1bf000000807264bc3f000000404df5b5bf000000a02bacc03f0000006018bf97bf000000605f12d03f000000a0450e623f000000407160c5bf000000c0d2c7c9bf000000a0a095be3f00000060081fbe3f0000004068f9c2bf000000600305babf000000008ffeb0bf00000040f6fbbfbf000000a0290f9b3f000000604f7ca73f000000e0b32880bf000000a0ae0eae3f000000c06be9adbf00000080a77bd0bf000000608ddeb7bf00000080c4adc1bf000000e0586ead3f0000006038ceaabf0000004066f0ab3f000000e00028a03f000000e0ba28c3bf000000202f46adbf0000008039989dbf00000000c3b68d3f000000c0839a843f000000a0057cb0bf00000020f3a5bb3f000000008e0155bf00000000b4c8c1bf00000000d56cbbbf0000000050fb6e3f000000e0c5a0cf3f0000000016a4c23f000000a00c0bb3bf000000c0f3ae7b3f0000000079bea23f000000c074adb23f000000403319cdbf000000804539913f000000000cd4b03f00000040ad4ac23f000000004279ab3f00000060b4c4b63f000000c04ad8bfbf000000e0204a90bf00000080301d763f000000a06c6dc6bf00000020a99b9e3f00000080a3c29f3f000000c09d11babf000000006060b7bf000000a0bd8984bf00000000a5b0c13f00000060d7c5ba3f000000c0192db2bf00000040e7fbc4bf0000004089fcbf3f00000000f045c4bf00000000d3a2a7bf000000a0731dc03f000000c03cf4b7bf000000a0c85bb8bf00000080aa66cfbf00000080eec3b33f00000080eb75d33f00000000277bb43f000000a08f69cabf00000020c44295bf000000a024f5cabf000000c04911b13f000000803f57ab3f00000040104c64bf000000e08d4fa0bf000000808876b23f00000020c60ac4bf00000080cb5a9abf00000020dcf7b73f000000c0e0d8abbf0000002078baa3bf000000c04998ce3f0000008028cb66bf000000e0aff6843f000000c0b166923f000000a0e2a8aabf000000805e99943f00000020e4a5923f000000c06990b4bf000000809b1aa4bf00000060e5abb93f000000402bf7b1bf000000403f118c3f000000a08816ae3f000000602e3fc9bf000000e0aa52be3f000000401cdcb33f00000020014ba23f000000806000a43f0000004039aaa63f00000000b5fbbfbf0000008064cbb3bf000000a04018be3f000000400a0fcbbf000000e020d1c23f000000806278c63f00000080bf3ca8bf000000e000a0ba3f000000e002b38abf00000060d915b63f00000060262eb3bf000000c0e859bbbf00000000bb2da2bf000000a0d6aa56bf00000020ffa2ac3f00000020739f933f000000c0e975b1bf00000000e1255f3f94749462652e	\\x80049508090000000000005d945d9428470000000000000000470000000000000000473fc01ac180000000470000000000000000470000000000000000470000000000000000473fa5ca7ea0000000470000000000000000473fc2ec3e20000000470000000000000000473fc46a8100000000473fb7df6b00000000473fa8577f40000000470000000000000000470000000000000000470000000000000000473fc6db3ca0000000470000000000000000470000000000000000473fc6344160000000473faed5dbc0000000473f90b58700000000470000000000000000470000000000000000470000000000000000473fab5a5380000000470000000000000000473fa2c4be80000000470000000000000000470000000000000000473fc14f0920000000473f78a3a6a0000000470000000000000000470000000000000000470000000000000000473fa8a33300000000473fc0ae56e0000000470000000000000000470000000000000000470000000000000000470000000000000000470000000000000000473fb81f2c60000000470000000000000000470000000000000000470000000000000000473f8c155e00000000473f76e80de0000000473f9ddb9e60000000470000000000000000470000000000000000473fc48be500000000470000000000000000470000000000000000470000000000000000470000000000000000470000000000000000470000000000000000473fc725cc60000000473fab9fd740000000470000000000000000470000000000000000473f763df040000000473f812a3f80000000470000000000000000470000000000000000473fcb5258c0000000473fc6ad0540000000470000000000000000470000000000000000470000000000000000473f93ea0e40000000470000000000000000473fc2ef0be0000000470000000000000000470000000000000000470000000000000000473fc24af080000000470000000000000000473fc73164c0000000470000000000000000473fb2360c80000000473fa14e7ee0000000473fadae6d20000000470000000000000000470000000000000000470000000000000000473fb26a54c0000000470000000000000000473fb4ac5f20000000473fa509e040000000470000000000000000470000000000000000470000000000000000473f6687eac0000000470000000000000000470000000000000000470000000000000000470000000000000000470000000000000000470000000000000000470000000000000000473f5ed03dc0000000473fa0cacd20000000473f991ecde0000000473fa27afb20000000470000000000000000470000000000000000473f9cb4e080000000473fab4a9a20000000470000000000000000473fa153c040000000470000000000000000473fb848cca0000000473fa8da0300000000470000000000000000470000000000000000473f913441a0000000473f64857d40000000470000000000000000473fa00f64a0000000473f96760bc0000000473fc49f1c80000000470000000000000000473fb519a1a0000000473f9da67620000000473fc0a5e8a0000000473fc28e44c0000000473f96b5be20000000470000000000000000470000000000000000470000000000000000473f8daaf360000000473f7f2a7560000000473f9610e9c0000000470000000000000000470000000000000000470000000000000000473fb4401f40000000473fa48e1ea0000000470000000000000000470000000000000000473fbc8ea220000000470000000000000000473f84211040000000473fb52e1cc0000000473f9001ea00000000470000000000000000470000000000000000473f81060440000000473fb97805c0000000473fbaa669a0000000470000000000000000470000000000000000470000000000000000473fbc112ac0000000470000000000000000470000000000000000473fa3511520000000473fc23a9c80000000473fbfc48260000000470000000000000000473fada25980000000473fab528d60000000473f48715760000000473fbc8c6860000000473fa77db2a0000000473f94566ae0000000473fb99a6020000000473fc798b780000000470000000000000000470000000000000000470000000000000000470000000000000000470000000000000000473fc2e62620000000473f969d0240000000473fc2b26980000000473fa81ca800000000470000000000000000473fc3a79bc0000000473f974394a0000000470000000000000000473f90330f20000000473fa17bb120000000470000000000000000470000000000000000473faebee420000000470000000000000000470000000000000000473f73793220000000473fa7233ee0000000470000000000000000473f9d739e60000000470000000000000000473f817f74e0000000473f8932ca80000000473fa19d2a60000000473fc1eb4f20000000473f6271d640000000473f81fec000000000473f8283c100000000470000000000000000470000000000000000470000000000000000473fb8d93fe0000000470000000000000000473fa6c1c320000000473f70203ae0000000470000000000000000470000000000000000470000000000000000473fb8dfd9e0000000473fa0765440000000470000000000000000473f30a78c00000000470000000000000000473fb27574a0000000473facc576c0000000470000000000000000473f7b1675c0000000470000000000000000470000000000000000470000000000000000470000000000000000470000000000000000473fbbc1e7e0000000473f4c9e48e0000000470000000000000000470000000000000000473f8f495680000000470000000000000000470000000000000000470000000000000000470000000000000000473facfa5e00000000473fb42a5ba0000000473fb58bce80000000473fc0104160000000473fbe3f8fa0000000473fc2798100000000470000000000000000473f94494a40000000473fc1c6fb00000000470000000000000000473fb32927a0000000473fd1012680000000470000000000000000473fb6766da0000000470000000000000000470000000000000000473f9d245a20000000470000000000000000470000000000000000473f9b12136000000047000000000000000065612e	admin	2025-05-28 08:44:48.370597	2025-05-28 08:44:48.394059
3	Rahul	Chiramel	rahch515	rahch515@student.liu.se	{"likes": ["Aeroplanes", "Automation"]}	/images/rahch515.jpg	{"last_task": "Screw object", "successful_tasks": 10}	\\x8004958e040000000000005d948c156e756d70792e636f72652e6d756c74696172726179948c0c5f7265636f6e7374727563749493948c056e756d7079948c076e6461727261799493944b0085944301629487945294284b014b80859468048c0564747970659493948c02663894898887945294284b038c013c944e4e4e4affffffff4affffffff4b00749462894200040000000000c01258c0bf000000c0f7fdaf3f00000040085dbb3f00000040500faebf000000c0422ea7bf00000080a504b0bf000000c0d9f48a3f000000c0e61f91bf000000203ffeca3f00000000383cb4bf000000c02cf0cb3f00000040572d7e3f000000203762c9bf0000002055bfc2bf000000c0790b913f00000000eb10ad3f000000601c54b9bf00000040babbb4bf00000040d304afbf0000002013fdb6bf000000805be49a3f00000060d6949abf000000806854963f000000405367a83f000000c07c09b9bf000000403cb6d6bf000000c070c3b6bf00000080974cc7bf000000c01d85bc3f000000209b08bdbf00000040f22683bf000000c042577d3f00000000da5bbfbf000000c0dac6adbf000000e0e603b6bf000000a0fda7af3f000000c0b3e7843f000000807a6fb1bf000000e0cfc0c53f0000000063219abf000000805827c1bf0000000072f7c0bf000000a0d204a4bf00000000d68eca3f000000603d23c33f000000c04f6a8e3f000000a06fd1a13f00000020c87380bf000000c074d5bc3f0000008049c2c9bf000000401cfeb53f000000c0795cbc3f00000060cecfbc3f000000408170993f000000e075d7c33f00000040d242c0bf000000007972a13f000000400fa2b03f000000802a3dcebf000000e041ec993f00000000c97e74bf000000a0998d98bf00000080b5d7b8bf000000c0a2e1a7bf000000c079c0c83f0000002000c1c23f00000040a79ca9bf0000008098a4babf000000c01edec53f000000801e1ec9bf00000080a792933f000000803aebb53f000000007a76bcbf00000040ad39bebf0000004077facdbf000000a0cc82b33f000000c0ad72d63f000000404242cc3f00000060f2bdbdbf000000c09472923f00000080d23cc0bf00000060f352a5bf000000200598ab3f000000606cdd95bf000000c0c324c4bf000000a0ce7cad3f0000004045f1b6bf000000c0c593a53f000000c0c058ad3f000000404fb5953f000000c0d15b90bf000000409eedc13f000000005b219ebf00000020e716a43f000000c0f9cc883f0000004051b4b3bf000000805510b7bf0000006098c88a3f00000020b280afbf000000c040859abf000000209d38c43f000000201186b8bf00000000c6f1a93f00000060e4f3a83f00000020388fc8bf00000020962cb03f000000a0045d793f00000000b2d7a2bf00000040009ba63f000000c0c6569e3f000000c07d60c1bf000000c06205a8bf00000020cd93c83f00000060020ac8bf000000e0ceaac53f000000c0bbb8c13f0000006079a7833f0000004014ecc13f000000c03b6db03f00000080e308b23f00000080bd5ba7bf0000008003b7b3bf000000c01f50b6bf000000a0f7fe66bf000000c01971a93f00000040b5e2a8bf00000040e2b8b03f00000000cccb43bf94749462612e	\N	admin	2025-05-28 08:44:48.370597	2025-05-28 08:44:48.394059
23	Sanjay	Nambiar	sanna058	sanna058@student.liu.se	{}	C:\\Users\\oscik559\\Projects\\mini_project_repo\\mini_project\\assets\\face_capture\\sanna058.jpg	[]	\\x8004958e040000000000005d948c156e756d70792e636f72652e6d756c74696172726179948c0c5f7265636f6e7374727563749493948c056e756d7079948c076e6461727261799493944b0085944301629487945294284b014b80859468048c0564747970659493948c02663894898887945294284b038c013c944e4e4e4affffffff4affffffff4b00749462894200040000000000a0eb4269bf00000040af06bb3f000000c048fe89bf000000800605b0bf000000c0c06b73bf000000206a09abbf00000000a764abbf000000206ef5b0bf000000806a57bb3f00000060dbb3aebf000000a0e84aca3f000000202c3093bf00000000096fcdbf000000e0ecbfc3bf000000e02c3392bf0000008035cac13f000000e0e4cdc6bf000000e0b64ab5bf00000040813ba3bf000000c01052a3bf000000a0bbbe8bbf0000000074d5853f0000000000dbb63f000000200951b83f00000040e830a2bf000000c051f0d4bf000000a0492ea8bf00000000c447c0bf0000008098e2913f000000c076ffb1bf000000a08a51b0bf000000807f48b83f00000040fcbec1bf000000605973a7bf0000000051e6923f000000c0a08cb73f000000a0dbba97bf0000002049ce94bf000000a009d2cb3f000000201a73a43f00000000929eb2bf000000e0a91eb3bf000000401faaa43f0000008071c1d23f00000020b21cce3f000000e083d0b43f000000c052348d3f00000000354ca03f0000006013b5c03f000000c08b08d2bf00000000f9a9ae3f000000e0c820b73f0000008069f4c13f000000803c038d3f000000805d9db83f000000c084a3c5bf00000000d4aa7e3f000000003685a63f000000a0095bbdbf00000000cd91993f000000e02ca69ebf00000080303ba7bf00000080e5b8a7bf000000005dfda8bf000000c0e2ecd13f000000a060e1ab3f0000006007dac1bf000000603cc3a0bf000000008c7cbb3f000000c06314c4bf000000a06ffaadbf0000008086af9c3f000000603049bdbf000000c0b550bcbf0000006063f2d2bf00000000bb07673f000000006c09d43f000000808e99c53f000000a0ed64c4bf00000000104b8f3f000000e0d456a8bf000000c0e7d798bf00000040a7f0b53f000000004a91a53f000000a0f91eb7bf000000a0c3cc85bf000000c09dedc1bf00000000341f8fbf000000e0af3cc13f00000040887aa9bf000000a02738b4bf000000601ff0c53f000000002236b1bf00000040b031c13f000000c064d08ebf00000000bc08a1bf000000a049c7a7bf00000060a533973f000000c00300c1bf000000c0b07f953f0000008037c3b13f00000000fe67b2bf0000002069f294bf00000080dbe5b93f000000602d84c4bf0000000060c48e3f000000e01a797bbf000000207a58903f00000000b189a73f000000a04a5eac3f000000602a24cabf00000060f19cb3bf000000e05b60c13f0000000087b3cdbf000000e05cebc33f000000e00b5ac83f0000004056338abf000000a0d5d3b73f000000a0a6eeb93f00000080539baa3f000000204d55753f000000803851a9bf00000020ba2dc3bf00000040261bb8bf000000e0875db43f00000000be58813f00000060072aac3f000000409ea07f3f94749462612e	\\x80049508090000000000005d945d9428473fb63637c0000000470000000000000000473f9c2df480000000470000000000000000473f5d37dce0000000473f702a1500000000473fc0258420000000470000000000000000473f53fc57e0000000470000000000000000473f9c27a4a0000000473f8e68c6c0000000473f8ed7e700000000473f6f529c20000000473f6cca04a0000000470000000000000000473fbf112400000000473f986d81e0000000470000000000000000473f85e23f40000000473f9fa85ca0000000473f8c2b5c60000000470000000000000000470000000000000000470000000000000000473fa2b578c0000000470000000000000000473fba2d9720000000470000000000000000470000000000000000470000000000000000473f7462a140000000470000000000000000473f9165dd80000000473faa37ed60000000473fb823e400000000473fb8fcf500000000470000000000000000473f605b9ca0000000473fbb5520c0000000470000000000000000473f698c1b00000000473fbbcd67e0000000473f8e4e1660000000473fb179ab00000000470000000000000000473f72bb0280000000473f7a96b620000000470000000000000000470000000000000000470000000000000000473fc45e2dc0000000470000000000000000470000000000000000473f6c99ae40000000470000000000000000473fb3626c80000000470000000000000000470000000000000000473fb555dc20000000473f4acc28e0000000470000000000000000473fc8c95080000000473fa17346e0000000473f9c8c71c0000000470000000000000000473fbc59a8c0000000473faf29c4e0000000470000000000000000470000000000000000470000000000000000473f9308bd60000000470000000000000000473f79326fc0000000473f91842a40000000470000000000000000470000000000000000473fc17e0ce0000000473fb0b70ea0000000473fa9485660000000470000000000000000470000000000000000473fcc4f0a40000000470000000000000000470000000000000000473f826718e0000000473f7860e000000000470000000000000000470000000000000000473fa69bb280000000473fbd3f2940000000470000000000000000470000000000000000470000000000000000470000000000000000470000000000000000473f684fb7c0000000470000000000000000470000000000000000470000000000000000470000000000000000470000000000000000473f683d97c0000000473fb53de020000000473f95ada280000000473f8ca83960000000473f66ace560000000473f9ab40560000000470000000000000000473fc2b0db80000000470000000000000000473fa6fb3140000000473f64c89920000000473fbb355d80000000473faa5afc20000000470000000000000000473fa04a42c0000000473f828fb7e0000000473f999eca00000000473f81516c60000000470000000000000000473fb726f420000000473fa421be40000000473f93c0b580000000473fc8695e60000000473fbbbec340000000473fb33b4aa0000000473fc1b70be0000000473f14904b40000000470000000000000000473fa4052f80000000470000000000000000473fcbec7220000000473fae6f02e0000000473f9e1d3e40000000473fb4c0eb20000000473fa079e080000000470000000000000000473fa157c040000000473f9fbdbfa0000000470000000000000000470000000000000000473fc21bbda0000000473fa3475560000000470000000000000000473f946b9e00000000473fb69f9300000000470000000000000000473fbe040900000000473fab8927e0000000473fc01568e0000000473fc4cea600000000470000000000000000473f90215200000000470000000000000000473fc04470a0000000470000000000000000470000000000000000473faae53800000000470000000000000000473fc078c300000000470000000000000000473f946b6be0000000470000000000000000473fb6c07540000000473fc4fd1120000000473fb0e96120000000473fad8e4340000000473f8af70220000000473fbfc8e340000000470000000000000000470000000000000000473fbf5a5c80000000473f43d0c520000000470000000000000000473fa3fdc280000000473fa81aa440000000473fa3b0ee80000000473f5199be80000000473f7530a040000000473fb8099f60000000473f9aa0f120000000470000000000000000473fb60d28c0000000473f8eed39a0000000470000000000000000470000000000000000473fc00cdcc0000000470000000000000000470000000000000000473fc20fc460000000473fb690c340000000470000000000000000473fcebbfb40000000470000000000000000470000000000000000473fa25ba7c0000000473fc6686ce0000000473fb18f29c0000000473f8cb063c0000000473fa12c5380000000473f90f4e160000000470000000000000000470000000000000000470000000000000000470000000000000000473f31466f80000000470000000000000000473f7cda4b40000000470000000000000000470000000000000000470000000000000000473f7298c9e0000000473f6d86d6e0000000470000000000000000473f6d93fc80000000470000000000000000473fb7ea4a40000000473f9d8437c0000000470000000000000000473f3d1d0a40000000473fa665d0e0000000473f56de6980000000470000000000000000470000000000000000470000000000000000473f9e92e6c0000000473f66046a60000000470000000000000000470000000000000000473f8f205e20000000470000000000000000473fa76109e0000000470000000000000000470000000000000000473fb3377660000000473fc48066a0000000473fb945f240000000473fb9aae3e0000000473fb35acc80000000473fbeb3cca0000000473f7b1dabe0000000473f90abcf60000000473fca0191a0000000470000000000000000473f9e8edfe0000000473f9b952040000000470000000000000000473fc123b360000000473fbbfe1b80000000470000000000000000473f9712ce20000000470000000000000000470000000000000000473f9b33a8c000000047000000000000000065612e	guest	2025-05-16 11:43:05.827043	2025-05-16 11:43:05.827043
\.


--
-- Data for Name: voice_instructions; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.voice_instructions (id, session_id, transcribed_text, confidence, language, processed, "timestamp") FROM stdin;
\.


--
-- Name: camera_vision_object_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.camera_vision_object_id_seq', 1, false);


--
-- Name: drop_op_parameters_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.drop_op_parameters_sequence_id_seq', 1, false);


--
-- Name: gesture_instructions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.gesture_instructions_id_seq', 1, false);


--
-- Name: gesture_library_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.gesture_library_id_seq', 6, true);


--
-- Name: instruction_operation_sequence_task_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.instruction_operation_sequence_task_id_seq', 1, false);


--
-- Name: instructions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.instructions_id_seq', 2, true);


--
-- Name: interaction_memory_interaction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.interaction_memory_interaction_id_seq', 3, true);


--
-- Name: isaac_sim_gui_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.isaac_sim_gui_sequence_id_seq', 3, true);


--
-- Name: lift_state_parameters_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.lift_state_parameters_sequence_id_seq', 1, false);


--
-- Name: operation_library_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.operation_library_id_seq', 2, true);


--
-- Name: operation_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.operation_sequence_id_seq', 1, false);


--
-- Name: pick_op_parameters_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.pick_op_parameters_sequence_id_seq', 1, false);


--
-- Name: rotate_state_parameters_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.rotate_state_parameters_sequence_id_seq', 1, false);


--
-- Name: screw_op_parameters_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.screw_op_parameters_sequence_id_seq', 1, false);


--
-- Name: sequence_library_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.sequence_library_sequence_id_seq', 6, true);


--
-- Name: simulation_results_simulation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.simulation_results_simulation_id_seq', 2, true);


--
-- Name: skills_skill_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.skills_skill_id_seq', 2, true);


--
-- Name: slide_state_parameters_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.slide_state_parameters_sequence_id_seq', 1, false);


--
-- Name: sort_order_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.sort_order_order_id_seq', 1, false);


--
-- Name: states_task_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.states_task_id_seq', 2, true);


--
-- Name: task_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.task_history_id_seq', 1, false);


--
-- Name: task_preferences_preference_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.task_preferences_preference_id_seq', 3, true);


--
-- Name: task_templates_task_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.task_templates_task_id_seq', 4, true);


--
-- Name: travel_op_parameters_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.travel_op_parameters_sequence_id_seq', 1, false);


--
-- Name: unified_instructions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.unified_instructions_id_seq', 1, false);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.users_user_id_seq', 23, true);


--
-- Name: voice_instructions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.voice_instructions_id_seq', 1, false);


--
-- Name: access_logs access_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.access_logs
    ADD CONSTRAINT access_logs_pkey PRIMARY KEY (log_id);


--
-- Name: camera_vision camera_vision_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.camera_vision
    ADD CONSTRAINT camera_vision_pkey PRIMARY KEY (object_id);


--
-- Name: drop_op_parameters drop_op_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.drop_op_parameters
    ADD CONSTRAINT drop_op_parameters_pkey PRIMARY KEY (sequence_id);


--
-- Name: gesture_instructions gesture_instructions_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.gesture_instructions
    ADD CONSTRAINT gesture_instructions_pkey PRIMARY KEY (id);


--
-- Name: gesture_library gesture_library_gesture_type_key; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.gesture_library
    ADD CONSTRAINT gesture_library_gesture_type_key UNIQUE (gesture_type);


--
-- Name: gesture_library gesture_library_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.gesture_library
    ADD CONSTRAINT gesture_library_pkey PRIMARY KEY (id);


--
-- Name: instruction_operation_sequence instruction_operation_sequence_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.instruction_operation_sequence
    ADD CONSTRAINT instruction_operation_sequence_pkey PRIMARY KEY (task_id);


--
-- Name: instructions instructions_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.instructions
    ADD CONSTRAINT instructions_pkey PRIMARY KEY (id);


--
-- Name: instructions instructions_sync_id_key; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.instructions
    ADD CONSTRAINT instructions_sync_id_key UNIQUE (sync_id);


--
-- Name: interaction_memory interaction_memory_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.interaction_memory
    ADD CONSTRAINT interaction_memory_pkey PRIMARY KEY (interaction_id);


--
-- Name: isaac_sim_gui isaac_sim_gui_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.isaac_sim_gui
    ADD CONSTRAINT isaac_sim_gui_pkey PRIMARY KEY (sequence_id);


--
-- Name: lift_state_parameters lift_state_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.lift_state_parameters
    ADD CONSTRAINT lift_state_parameters_pkey PRIMARY KEY (sequence_id);


--
-- Name: operation_library operation_library_operation_name_key; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.operation_library
    ADD CONSTRAINT operation_library_operation_name_key UNIQUE (operation_name);


--
-- Name: operation_library operation_library_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.operation_library
    ADD CONSTRAINT operation_library_pkey PRIMARY KEY (id);


--
-- Name: operation_sequence operation_sequence_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.operation_sequence
    ADD CONSTRAINT operation_sequence_pkey PRIMARY KEY (id);


--
-- Name: pick_op_parameters pick_op_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.pick_op_parameters
    ADD CONSTRAINT pick_op_parameters_pkey PRIMARY KEY (sequence_id);


--
-- Name: rotate_state_parameters rotate_state_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.rotate_state_parameters
    ADD CONSTRAINT rotate_state_parameters_pkey PRIMARY KEY (sequence_id);


--
-- Name: screw_op_parameters screw_op_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.screw_op_parameters
    ADD CONSTRAINT screw_op_parameters_pkey PRIMARY KEY (sequence_id);


--
-- Name: sequence_library sequence_library_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.sequence_library
    ADD CONSTRAINT sequence_library_pkey PRIMARY KEY (sequence_id);


--
-- Name: simulation_results simulation_results_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.simulation_results
    ADD CONSTRAINT simulation_results_pkey PRIMARY KEY (simulation_id);


--
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (skill_id);


--
-- Name: skills skills_skill_name_key; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_skill_name_key UNIQUE (skill_name);


--
-- Name: slide_state_parameters slide_state_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.slide_state_parameters
    ADD CONSTRAINT slide_state_parameters_pkey PRIMARY KEY (sequence_id);


--
-- Name: sort_order sort_order_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.sort_order
    ADD CONSTRAINT sort_order_pkey PRIMARY KEY (order_id);


--
-- Name: states states_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.states
    ADD CONSTRAINT states_pkey PRIMARY KEY (task_id);


--
-- Name: task_history task_history_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.task_history
    ADD CONSTRAINT task_history_pkey PRIMARY KEY (id);


--
-- Name: task_preferences task_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.task_preferences
    ADD CONSTRAINT task_preferences_pkey PRIMARY KEY (preference_id);


--
-- Name: task_templates task_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.task_templates
    ADD CONSTRAINT task_templates_pkey PRIMARY KEY (task_id);


--
-- Name: task_templates task_templates_task_name_key; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.task_templates
    ADD CONSTRAINT task_templates_task_name_key UNIQUE (task_name);


--
-- Name: travel_op_parameters travel_op_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.travel_op_parameters
    ADD CONSTRAINT travel_op_parameters_pkey PRIMARY KEY (sequence_id);


--
-- Name: unified_instructions unified_instructions_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.unified_instructions
    ADD CONSTRAINT unified_instructions_pkey PRIMARY KEY (id);


--
-- Name: usd_data usd_data_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.usd_data
    ADD CONSTRAINT usd_data_pkey PRIMARY KEY (sequence_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_liu_id_key; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_liu_id_key UNIQUE (liu_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: voice_instructions voice_instructions_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.voice_instructions
    ADD CONSTRAINT voice_instructions_pkey PRIMARY KEY (id);


--
-- Name: idx_camera_vision_last_detected; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_camera_vision_last_detected ON public.camera_vision USING btree (last_detected);


--
-- Name: idx_conv_memory_instruction; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_conv_memory_instruction ON public.interaction_memory USING btree (instruction_id);


--
-- Name: idx_interaction_memory_user_id; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_interaction_memory_user_id ON public.interaction_memory USING btree (user_id);


--
-- Name: idx_operation_sequence_object; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_operation_sequence_object ON public.instruction_operation_sequence USING btree (object_id);


--
-- Name: idx_simulation_instruction; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_simulation_instruction ON public.simulation_results USING btree (instruction_id);


--
-- Name: idx_skills_name; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_skills_name ON public.skills USING btree (skill_name);


--
-- Name: idx_task_preferences_user_id; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_task_preferences_user_id ON public.task_preferences USING btree (user_id);


--
-- Name: idx_task_templates_name; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_task_templates_name ON public.task_templates USING btree (task_name);


--
-- Name: idx_task_templates_sequence; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_task_templates_sequence ON public.task_templates USING btree (default_sequence);


--
-- Name: idx_unified_instructions_session_id; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_unified_instructions_session_id ON public.unified_instructions USING btree (session_id);


--
-- Name: idx_user_prefs_task; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_user_prefs_task ON public.task_preferences USING btree (user_id, task_id);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: idx_users_liu_id; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_users_liu_id ON public.users USING btree (liu_id);


--
-- Name: idx_voice_processed; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_voice_processed ON public.voice_instructions USING btree (processed);


--
-- Name: idx_voice_session_id; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_voice_session_id ON public.voice_instructions USING btree (session_id);


--
-- Name: access_logs access_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.access_logs
    ADD CONSTRAINT access_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- Name: instruction_operation_sequence instruction_operation_sequence_instruction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.instruction_operation_sequence
    ADD CONSTRAINT instruction_operation_sequence_instruction_id_fkey FOREIGN KEY (instruction_id) REFERENCES public.instructions(id) ON DELETE CASCADE;


--
-- Name: instruction_operation_sequence instruction_operation_sequence_object_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.instruction_operation_sequence
    ADD CONSTRAINT instruction_operation_sequence_object_id_fkey FOREIGN KEY (object_id) REFERENCES public.camera_vision(object_id);


--
-- Name: instruction_operation_sequence instruction_operation_sequence_sequence_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.instruction_operation_sequence
    ADD CONSTRAINT instruction_operation_sequence_sequence_id_fkey FOREIGN KEY (sequence_id) REFERENCES public.sequence_library(sequence_id);


--
-- Name: instruction_operation_sequence instruction_operation_sequence_skill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.instruction_operation_sequence
    ADD CONSTRAINT instruction_operation_sequence_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES public.skills(skill_id);


--
-- Name: instructions instructions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.instructions
    ADD CONSTRAINT instructions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: interaction_memory interaction_memory_instruction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.interaction_memory
    ADD CONSTRAINT interaction_memory_instruction_id_fkey FOREIGN KEY (instruction_id) REFERENCES public.instructions(id) ON DELETE CASCADE;


--
-- Name: interaction_memory interaction_memory_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.interaction_memory
    ADD CONSTRAINT interaction_memory_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: operation_sequence operation_sequence_command_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.operation_sequence
    ADD CONSTRAINT operation_sequence_command_id_fkey FOREIGN KEY (command_id) REFERENCES public.unified_instructions(id);


--
-- Name: operation_sequence operation_sequence_sequence_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.operation_sequence
    ADD CONSTRAINT operation_sequence_sequence_id_fkey FOREIGN KEY (sequence_id) REFERENCES public.sequence_library(sequence_id);


--
-- Name: simulation_results simulation_results_instruction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.simulation_results
    ADD CONSTRAINT simulation_results_instruction_id_fkey FOREIGN KEY (instruction_id) REFERENCES public.instructions(id) ON DELETE CASCADE;


--
-- Name: states states_sequence_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.states
    ADD CONSTRAINT states_sequence_id_fkey FOREIGN KEY (sequence_id) REFERENCES public.sequence_library(sequence_id) ON DELETE CASCADE;


--
-- Name: task_preferences task_preferences_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.task_preferences
    ADD CONSTRAINT task_preferences_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: unified_instructions unified_instructions_liu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.unified_instructions
    ADD CONSTRAINT unified_instructions_liu_id_fkey FOREIGN KEY (liu_id) REFERENCES public.users(liu_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

