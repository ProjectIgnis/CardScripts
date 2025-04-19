--究極時械神セフィロン (Anime)
--Sephylon, the Ultimate Timelord (Anime)
local s,id=GetID()
local LOCATION_HDG=LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Must be Special Summoned with "Infinite Light"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--Special Summon as many "Timelord" monsters as possible from your hand, Deck, and/or Graveyard
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Gains ATK equal to the combined ATK of all "Timelord" monsters you control
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	--Negate
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetTarget(function(e,_c) return _c==e:GetHandler():GetBattleTarget() end)
	c:RegisterEffect(e4)
	--Destroy replace
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e5:SetCondition(s.damcon)
	e5:SetOperation(s.damop)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetCode(EFFECT_DESTROY_REPLACE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTarget(s.reptg)
	e6:SetOperation(s.repop)
	c:RegisterEffect(e6)
end
s.listed_series={SET_TIMELORD}
s.listed_names={72883039,8967776}
function s.splimit(e,se,sp,st)
	return se:GetHandler():IsCode(72883039) or Duel.GetChainInfo(0,CHAININFO_TRIGGERING_CODE)==72883039
end
function s.filter(c,e,tp)
	return c:IsSetCard(SET_TIMELORD) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HDG,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HDG)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_HDG,0,ft,ft,nil,e,tp)
	local c=e:GetHandler()
	for tc in aux.Next(g) do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(4000)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end
function s.cfilter(c)
	return c:IsSetCard(SET_TIMELORD) and not c:IsCode(8967776) and c:IsFaceup()
end
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(s.cfilter,c:GetControler(),LOCATION_MZONE,0,nil)
	return g:GetSum(Card.GetAttack)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not bc or c:GetEffectCount(EFFECT_INDESTRUCTABLE_BATTLE)>0 then return false end
	if bc==Duel.GetAttackTarget() and bc:IsDefensePos() then return false end
	if c:IsAttackPos() and bc:IsDefensePos() and bc:GetEffectCount(EFFECT_DEFENSE_ATTACK)==1
		and c:GetAttack()<=bc:GetDefense() then return true end
	if c:IsAttackPos() and (bc:IsAttackPos() or bc:IsHasEffect(EFFECT_DEFENSE_ATTACK))
		and c:GetAttack()<=bc:GetAttack() then return true end
	if c:IsDefensePos() and bc:IsDefensePos() and bc:GetEffectCount(EFFECT_DEFENSE_ATTACK)==1
		and c:GetDefense()<bc:GetDefense() then return true end
	if c:IsDefensePos() and (bc:IsAttackPos() or bc:IsHasEffect(EFFECT_DEFENSE_ATTACK))
		and c:GetDefense()<bc:GetAttack() then return true end
	return false
end
function s.repfilter(c)
	return c:IsSetCard(SET_TIMELORD) and c:IsFaceup() and c:IsAbleToRemove()
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToBattle() and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_MZONE,0,1,c)
		and Duel.SelectEffectYesNo(tp,c,96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_MZONE,0,1,1,c)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE|PHASE_DAMAGE)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetReset(RESET_PHASE|PHASE_DAMAGE)
		c:RegisterEffect(e2)
	end
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT)
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_MZONE,0,1,c) end
	if Duel.SelectEffectYesNo(tp,c,96) then return true
	else return false end
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
	local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end