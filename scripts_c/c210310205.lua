--Tinsight Assembly - Element Cannon
--AlphaKretin
function c210310205.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsSetCard,0xf35),1,99)
	c:EnableReviveLimit()
	--repeat attack
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c210310205.atktg)
	e1:SetOperation(c210310205.atkop)
	c:RegisterEffect(e1)
	--return to extra
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17032740,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c210310205.rettg)
	e2:SetOperation(c210310205.retop)
	c:RegisterEffect(e2)
	--pierce
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
end
function c210310205.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local att=Duel.AnnounceAttribute(tp,1,0xff)
	e:SetLabel(att)
end
function c210310205.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local att=e:GetLabel()
	local e1=Effect.CreateEffect(c)
	e1:SetLabel(att)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_ALL)
	e1:SetValue(c210310205.atkfilter)
	c:RegisterEffect(e1)
end
function c210310205.atkfilter(e,c)
	return c:IsAttribute(e:GetLabel()) and c:IsFaceup()
end
function c210310205.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtra() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function c210310205.retfilter(c,e,tp)
	return c:GetReasonCard()==e:GetHandler() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c210310205.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if Duel.SendtoDeck(c,nil,2,REASON_EFFECT) then
		Duel.BreakEffect()
		if not Duel.IsPlayerAffectedByEffect(tp,59822133) 
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
			and Duel.IsExistingMatchingCard(c210310205.retfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
			and Duel.SelectYesNo(tp,aux.Stringid(4034,3)) then
				local g=Duel.GetMatchingGroup(c210310205.retfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
				for tc in aux.Next(g) do
					Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
					e1:SetValue(1)
					e1:SetReset(RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
					tc:RegisterEffect(e1)
					Duel.SpecialSummonComplete()
				end
			end
	end
end