--Tinsight Assembly - Dimension Shot
--AlphaKretin
function c210310204.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcMixN(c,true,true,c210310204.matfilter,2)
	aux.AddContactFusion(c,c210310204.contactfil,c210310204.contactop,c210310204.splimit)
	--repeat attack
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c210310204.atktg)
	e1:SetOperation(c210310204.atkop)
	c:RegisterEffect(e1)
	--return to extra
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17032740,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c210310204.rettg)
	e2:SetOperation(c210310204.retop)
	c:RegisterEffect(e2)
	--banish in battle
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31755044,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_BATTLED)
	e3:SetCountLimit(1)
	e3:SetCondition(c210310204.rmcon)
	e3:SetTarget(c210310204.rmtg)
	e3:SetOperation(c210310204.rmop)
	c:RegisterEffect(e3)
end
function c210310204.matfilter(c,fc,sumtype,tp)
	return c:IsSetCard(0xf35,fc,sumtype,tp) and c:IsType(TYPE_MONSTER,fc,sumtype,tp)
end
function c210310204.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,nil)
end
function c210310204.contactop(g,tp)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL)
end
function c210310204.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function c210310204.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	Duel.SetTargetParam(Duel.SelectOption(tp,1057,1056,1063,1073,1074,1076))
end
function c210310204.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local opt=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local ct=nil
	if opt==0 then ct=TYPE_RITUAL end
	if opt==1 then ct=TYPE_FUSION end
	if opt==2 then ct=TYPE_SYNCHRO end
	if opt==3 then ct=TYPE_XYZ end
	if opt==4 then ct=TYPE_PENDULUM end
	if opt==5 then ct=TYPE_LINK end
	local e1=Effect.CreateEffect(c)
	e1:SetLabel(ct)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_ALL)
	e1:SetValue(c210310204.atkfilter)
	c:RegisterEffect(e1)
end
function c210310204.atkfilter(e,c)
	return c:IsType(e:GetLabel()) and c:IsFaceup()
end
function c210310204.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtra() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function c210310204.retfilter(c,e,tp)
	return c:GetReasonCard()==e:GetHandler() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c210310204.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if Duel.SendtoDeck(c,nil,2,REASON_EFFECT) then
		Duel.BreakEffect()
		if not Duel.IsPlayerAffectedByEffect(tp,59822133) 
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
			and Duel.IsExistingMatchingCard(c210310204.retfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
			and Duel.SelectYesNo(tp,aux.Stringid(4034,3)) then
				local g=Duel.GetMatchingGroup(c210310204.retfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
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
function c210310204.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	e:SetLabelObject(bc)
	return bc and bc:IsStatus(STATUS_OPPO_BATTLE) and bc:IsRelateToBattle()
end
function c210310204.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabelObject():IsAbleToRemove() end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetLabelObject(),1,0,0)
end
function c210310204.rmop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsControler(1-tp) then
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end