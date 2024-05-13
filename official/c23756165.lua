--魅惑の女王 LV5
--Allure Queen LV5
local s,id=GetID()
function s.initial_effect(c)
	--Register if this card is Special Summoned by "Alure Queen LV3"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	--Special summon 1 "Allure Queen LV7" from your hand or Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_ALLURE_LVUP)
end
s.listed_names={87257460,50140163} --Allure Queen LV3, Allure Queen LV7
s.LVnum=5
s.LVset=SET_ALLURE_QUEEN
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetSummonType()==SUMMON_TYPE_SPECIAL+1 then
		--Equip a Level 5 or lower monster your opponent controls to this card
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetCategory(CATEGORY_EQUIP)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1)
		e1:SetCondition(s.eqcon1)
		e1:SetTarget(s.eqtg)
		e1:SetOperation(s.eqop)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		aux.AddEREquipLimit(c,s.eqcon1,s.eqval,s.equipop,e1,nil,RESET_EVENT|RESETS_STANDARD_DISABLE)
		--Quick Effect, if you are affected by "Golden Allure Queen"
		local e2=e1:Clone()
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetHintTiming(0,TIMING_END_PHASE)
		e2:SetCondition(s.eqcon2)
		c:RegisterEffect(e2)
		aux.AddEREquipLimit(c,s.eqcon2,s.eqval,s.equipop,e2,nil,RESET_EVENT|RESETS_STANDARD_DISABLE)
	end
end
function s.eqval(ec,c,tp)
	return ec:IsControler(1-tp) and c:HasLevel() and c:IsLevelBelow(5)
end
function s.eqcon1(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup():Filter(Card.HasFlagEffect,nil,id)
	return #g==0 and not Duel.IsPlayerAffectedByEffect(tp,CARD_GOLDEN_ALLURE_QUEEN)
end
function s.eqcon2(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup():Filter(Card.HasFlagEffect,nil,id)
	return #g==0 and Duel.IsPlayerAffectedByEffect(tp,CARD_GOLDEN_ALLURE_QUEEN)
end
function s.filter(c)
	return c:HasLevel() and c:IsLevelBelow(5) and c:IsFaceup() and c:IsAbleToChangeControler()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.equipop(c,e,tp,tc)
	if not c:EquipByEffectAndLimitRegister(e,tp,tc,id) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
	e1:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	e1:SetValue(s.repval)
	tc:RegisterEffect(e1)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		s.equipop(c,e,tp,tc)
	end
end
function s.repval(e,re,r,rp)
	return r&REASON_BATTLE~=0
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup():Filter(Card.HasFlagEffect,nil,id)
	return Duel.IsTurnPlayer(tp) and #g==1
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsCode(50140163) and c:IsCanBeSpecialSummoned(e,1,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if e:GetHandler():GetSequence()<5 then ft=ft+1 end
	if chk==0 then return ft>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,1,tp,tp,true,false,POS_FACEUP)>0 then
		tc:CompleteProcedure()
	end
end