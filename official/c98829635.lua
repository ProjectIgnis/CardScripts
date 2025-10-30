--禁じられた聖冠
--Forbidden Crown
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Apply these effects to 1 face-up monster on the field, until the end of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(aux.NOT(Card.HasFlagEffect),id),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetChainLimit(function(te) return not te:IsMonsterEffect() end)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,PLAYER_EITHER,LOCATION_MZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	local sc=Duel.SelectMatchingCard(tp,aux.FaceupFilter(aux.NOT(Card.HasFlagEffect),id),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	if sc then
		Duel.HintSelection(sc)
		local c=e:GetHandler()
		sc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
		--Its effects are negated
		sc:NegateEffects(c,RESETS_STANDARD_PHASE_END)
		--It cannot attack
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		sc:RegisterEffect(e1)
		--It cannot be destroyed by battle or card effects
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		sc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		sc:RegisterEffect(e3)
		--It is unaffected by other cards' activated effects, except its own
		local e4=e1:Clone()
		e4:SetCode(EFFECT_IMMUNE_EFFECT)
		e4:SetValue(function(e,re) return re:IsActivated() and e:GetHandler()~=re:GetOwner() end)
		sc:RegisterEffect(e4)
		--It cannot be Tributed
		local e5=e2:Clone()
		e5:SetCode(EFFECT_UNRELEASABLE_SUM)
		sc:RegisterEffect(e5)
		local e6=e2:Clone()
		e6:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		sc:RegisterEffect(e6)
		--It cannot be used as material for a Fusion, Synchro, Xyz, or Link Summon
		local e7=e1:Clone()
		e7:SetCode(EFFECT_CANNOT_BE_MATERIAL)
		e7:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
		sc:RegisterEffect(e7)
	end
end