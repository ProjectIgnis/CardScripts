--マインド・キャスリン
--Mind Castlin
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1+ non-Tuner monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--Switch control of 1 opponent's face-up monster and this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.cttg1)
	e1:SetOperation(s.ctop1)
	c:RegisterEffect(e1)
	--Switch control of 1 face-up monster on each field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.ctcon)
	e2:SetTarget(s.cttg2)
	e2:SetOperation(s.ctop2)
	c:RegisterEffect(e2)
end
function s.ctfilter(c,tp,e)
	return c:IsFaceup() and c:IsAbleToChangeControler() and Duel.GetMZoneCount(c:GetControler(),c,tp,LOCATION_REASON_CONTROL)>0
		and (not e or c:IsCanBeEffectTarget(e))
end
function s.cttg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.ctfilter(chkc,tp) end
	if chk==0 then return c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
		and Duel.IsExistingTarget(s.ctfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.ctfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	g:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,2,tp,0)
end
function s.ctop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		Duel.SwapControl(c,tc)
	end
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSynchroSummoned()
end
function s.cttg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.ctfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		and Duel.IsExistingTarget(s.ctfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	local g=Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp,e)
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetControler),1,tp,HINTMSG_CONTROL)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tg,2,tp,0)
end
function s.ctop2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==2 then
		Duel.SwapControl(tg:GetFirst(),tg:GetNext())
	end
end