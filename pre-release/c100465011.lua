--煉獄の零門
--Zero Gate of the Void
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Skip your next Draw Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMING_BATTLE_START|TIMING_END_PHASE)
	c:RegisterEffect(e1)
	--When an opponent's monster with ATK greater than or equal to your LP declares a direct attack and you have no cards in your hand: You can banish this card from your GY; negate the attack, and if you do, Special Summon 1 "Void Ogre Dragon" monster from your Extra Deck (this is treated as a Synchro Summon). While it is face-up in the Monster Zone, you take no damage. When it leaves the field, take 4000 damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.spcon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_VOID_OGRE_DRAGON}
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local turn_count=Duel.GetTurnCount()
	local reset_count=Duel.IsDrawPhase(tp) and 2 or 1
	--Skip your next Draw Phase
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_SKIP_DP)
	e1:SetTargetRange(1,0)
	e1:SetCondition(function(e)
		return Duel.GetTurnCount()~=turn_count
	end)
	e1:SetReset(RESET_PHASE|PHASE_DRAW|RESET_SELF_TURN,reset_count)
	Duel.RegisterEffect(e1,tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetAttacker()
	return bc and bc:IsControler(1-tp) and bc:IsAttackAbove(Duel.GetLP(tp)) and not Duel.GetAttackTarget()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_VOID_OGRE_DRAGON) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.NegateAttack() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
		sc:CompleteProcedure()
		local c=e:GetHandler()
		--While it is face-up in the Monster Zone, you take no damage
		local e1a=Effect.CreateEffect(c)
		e1a:SetType(EFFECT_TYPE_FIELD)
		e1a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET)
		e1a:SetCode(EFFECT_CHANGE_DAMAGE)
		e1a:SetRange(LOCATION_MZONE)
		e1a:SetTargetRange(1,0)
		e1a:SetValue(0)
		e1a:SetReset(RESET_EVENT|RESETS_STANDARD)
		sc:RegisterEffect(e1a,true)
		local e1b=e1a:Clone()
		e1b:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		sc:RegisterEffect(e1b,true)
		--When it leaves the field, take 4000 damage
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,3))
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EVENT_LEAVE_FIELD)
		e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			Duel.Hint(HINT_CARD,0,id)
			Duel.Damage(tp,4000,REASON_EFFECT)
			e:Reset()
		end)
		e2:SetReset(RESET_EVENT|RESET_OVERLAY|RESET_MSCHANGE|RESET_TURN_SET)
		sc:RegisterEffect(e2,true)
	end
end