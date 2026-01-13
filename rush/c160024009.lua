--冥跡のカーディ
--Qadi of the Monumenthes
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--Attack restriction
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsFaceup() and c:IsCode(160448004,160024008)
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and	Duel.IsExistingMatchingCard(s.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonPhaseMain() and c:IsStatus(STATUS_SUMMON_TURN+STATUS_SPSUMMON_TURN)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.tdfilter(c)
	return c:IsAbleToDeck() and c:IsMonster() and c:IsRace(RACE_BEASTWARRIOR)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	--Effect
	local c=e:GetHandler()
	--can only attack twice
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(s.atkcon)
	e1:SetReset(RESET_PHASE|PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetOperation(s.checkop)
	e2:SetReset(RESET_PHASE|PHASE_END,2)
	e2:SetLabelObject(e1)
	Duel.RegisterEffect(e2,tp)
	if Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,3,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local tg=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,3,3,nil)
		Duel.HintSelection(tg)
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function s.atkcon(e)
	return e:GetLabel()==2
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsTurnPlayer(1-e:GetHandlerPlayer()) then
		e:GetLabelObject():SetLabel(e:GetLabelObject():GetLabel()+1)
	end
end