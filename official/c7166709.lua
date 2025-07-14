--
--Steel-Stringed Sacrifice
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCost(s.effcost)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
function s.effcostfilter(c)
	return c:IsLevelAbove(5) and not c:IsPublic()
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.effcostfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rc=Duel.SelectMatchingCard(tp,s.effcostfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	Duel.ConfirmCards(1-tp,rc)
	Duel.ShuffleHand(tp)
	e:SetLabelObject(rc)
	e:SetLabel(rc:GetOriginalCodeRule())
	rc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
end
function s.thfilter(c)
	return c:IsLevelAbove(5) and c:IsAbleToHand()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=c:IsLocation(LOCATION_HAND) and not Duel.HasFlagEffect(tp,id)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local b2=c:IsLocation(LOCATION_GRAVE) and not Duel.HasFlagEffect(tp,id+1) and c:IsAbleToHand()
	local b3=c:IsLocation(LOCATION_GRAVE) and not Duel.HasFlagEffect(tp,id+2)
		and c:IsAbleToRemove() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,c)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)},
		{b3,aux.Stringid(id,4)})
	Duel.SetTargetParam(op)
	Duel.RegisterFlagEffect(tp,id+op-1,RESET_PHASE|PHASE_END,0,1)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
	elseif op==3 then
		e:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local code=e:GetLabel()
	local rc=e:GetLabelObject()
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,5))
	--Register if the player Normal Summons the revealed monster or a monster with the same original name
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp,eg,ep) return ep==tp and ((rc:HasFlagEffect(id) and eg:IsContains(rc) and rc:IsFaceup()) or eg:IsExists(aux.FaceupFilter(Card.IsOriginalCodeRule,code),1,nil)) end)
	e1:SetOperation(function(e) e:SetLabel(1) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--During the End Phase of this turn, lose 1000 LP if you did not Normal Summon the revealed monster, or a monster with the same original name
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,6))
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCondition(function() return e1:GetLabel()==0 end)
	e2:SetOperation(function(e,tp) Duel.SetLP(tp,Duel.GetLP(tp)-1000) end)
	Duel.RegisterEffect(e2,tp)
	if not c:IsRelateToEffect(e) then return end
	local op=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if op==1 then
		--Special Summon this card from your hand
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	elseif op==2 then
		--Add this card from your GY to your hand
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	elseif op==3 then
		--Banish this card from your GY, and if you do, add 1 Level 5 or higher monster from your GY to your hand
		if Duel.Remove(c,POS_FACEUP,REASON_EFFECT)==0 or not c:IsLocation(LOCATION_REMOVED) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end