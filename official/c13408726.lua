--メタトロンの影霊依
--Nekroz of Metaltron
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c)
	c:AddMustBeRitualSummoned()
	--Banish 1 Spell/Trap on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_REMOVE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.strmcon)
	e1:SetTarget(s.strmtg)
	e1:SetOperation(s.strmop)
	c:RegisterEffect(e1)
	--Banish this card until the End Phase and banish 1 face-up monster your opponent controls
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e2:SetCondition(function() return Duel.IsMainPhase() end)
	e2:SetTarget(s.mrmtg)
	e2:SetOperation(s.mrmop)
	c:RegisterEffect(e2)
	--Any monster destroyed by battle with your "Nekroz" monster is banished
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetValue(LOCATION_REMOVED)
	e3:SetTarget(function(e,c) return c:IsSetCard(SET_NEKROZ) end)
	c:RegisterEffect(e3)
end
s.listed_series={SET_NEKROZ}
function s.mat_filter(c)
	return not c:IsLevel(9)
end
function s.strmconfilter(c,tp)
	return c:IsSetCard(SET_NEKROZ) and c:IsPreviousControler(tp) and c:IsFaceup()
end
function s.strmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.strmconfilter,1,nil,tp)
end
function s.strmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsSpellTrap() and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(aux.AND(Card.IsSpellTrap,Card.IsAbleToRemove),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,aux.AND(Card.IsSpellTrap,Card.IsAbleToRemove),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
end
function s.strmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
function s.mrmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() and chkc:IsAbleToRemove() end
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsAbleToRemove),tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsAbleToRemove),tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g+c,2,tp,0)
end
function s.mrmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and aux.RemoveUntil(c,nil,REASON_EFFECT,PHASE_END,id,e,tp,aux.DefaultFieldReturnOp)
		and tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end