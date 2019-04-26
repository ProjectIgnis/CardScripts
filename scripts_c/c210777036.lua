--Necrofake
--designed by Preischadt#0402, scripted by Naim
function c210777036.initial_effect(c)
--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcMix(c,true,true,28297833,c210777036.matfilter)
	aux.AddContactFusion(c,c210777036.contactfil,c210777036.contactop,c210777036.splimit,c210777036.contactcon,1)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c210777036.splimit)
	c:RegisterEffect(e1)
	--to deck
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c210777036.sscd)
	e2:SetOperation(c210777036.ssop)
	c:RegisterEffect(e2)
	--change name
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CHANGE_CODE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(28297833)
	c:RegisterEffect(e3)
end
function c210777036.matfilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_ZOMBIE,fc,sumtype,tp) or c:IsAttribute(ATTRIBUTE_DARK,fc,sumtype,tp)
end
function c210777036.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
end
function c210777036.contactcon(tp)
    return Duel.GetFlagEffect(tp,210777036)==0
end
function c210777036.contactop(g,tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST+REASON_MATERIAL)
	Duel.RegisterFlagEffect(tp,210777036,RESET_PHASE+PHASE_END,0,1)
end
function c210777036.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
function c210777036.sscd(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
end
function c210777036.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(210777036,1))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_EVENT+0x2fe0000+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
	e1:SetCondition(c210777036.tdcond)
	e1:SetOperation(c210777036.tdop)
	c:RegisterEffect(e1)
end
function c210777036.tdcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c210777036.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,LOCATION_REMOVED,LOCATION_REMOVED)
	Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
end	
