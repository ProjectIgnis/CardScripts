--魅惑の女王 ＬＶ５
--Allure Queen LV5
local s,id=GetID()
function s.initial_effect(c)
	--Register that it was Special Summoned by the effect of "Allure Queen LV3"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.regcon)
	e0:SetOperation(function(e) e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~RESET_TEMP_REMOVE,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2)) end)
	c:RegisterEffect(e0)
	--Equip 1 Level 5 or lower monster your opponent controls to this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCondition(s.eqconignition)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c,s.eqconignition,s.eqval,s.equipop,e1)
	--Quick Effect version for when the effect of "Golden Allure Queen" is applied
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_STANDBY_PHASE,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCondition(s.eqconquick)
	c:RegisterEffect(e2)
	aux.AddEREquipLimit(c,s.eqconquick,s.eqval,s.equipop,e2)
	--Special Summon 1 "Allure Queen LV7" from your hand or Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) and e:GetHandler():GetEquipGroup():IsExists(Card.HasFlagEffect,1,nil,id) end)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	e3:SetLabelObject(e1)
	c:RegisterEffect(e3,false,REGISTER_FLAG_ALLURE_LVUP)
end
s.listed_names={87257460,50140163} --"Allure Queen LV3", "Allure Queen LV7"
s.LVnum=5
s.LVset=SET_ALLURE_QUEEN
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local trig_loc,trig_code1,trig_code2=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
	if not Duel.IsChainSolving() or (rc:IsRelateToEffect(re) and rc:IsFaceup() and rc:IsLocation(trig_loc)) then
		return rc:IsCode(87257460)
	end
	return trig_code1==87257460 or trig_code2==87257460
end
function s.eqconignition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:HasFlagEffect(id) and not c:GetEquipGroup():IsExists(Card.HasFlagEffect,1,nil,id) and not (c:IsOriginalSetCard(SET_ALLURE_QUEEN) and Duel.IsPlayerAffectedByEffect(tp,EFFECT_GOLDEN_ALLURE_QUEEN))
end
function s.eqconquick(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:HasFlagEffect(id) and not c:GetEquipGroup():IsExists(Card.HasFlagEffect,1,nil,id) and c:IsOriginalSetCard(SET_ALLURE_QUEEN) and Duel.IsPlayerAffectedByEffect(tp,EFFECT_GOLDEN_ALLURE_QUEEN)
end
function s.eqfilter(c)
	return c:IsLevelBelow(5) and c:IsFaceup() and c:IsAbleToChangeControler()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,tp,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0) then
		Duel.SendtoGrave(c,REASON_RULE,PLAYER_NONE,PLAYER_NONE)
	else
		s.equipop(c,e,tp,tc)
	end
end
function s.equipop(c,e,tp,tc)
	if not c:EquipByEffectAndLimitRegister(e,tp,tc,id) then return end
	--If this card would be destroyed by battle, the equipped monster is destroyed instead
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
	e1:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e1:SetValue(function(e,re,r,rp) return r&REASON_BATTLE>0 end)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e1)
end
function s.eqval(ec,c,tp)
	return ec:IsControler(1-tp) and ec:IsLevelBelow(5)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsCode(50140163) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end