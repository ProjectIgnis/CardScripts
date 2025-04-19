--魔将キメルーラ
--Kimeruler the Dark Raider

local s,id=GetID()
function s.initial_effect(c)
	--Can attack directly
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.dircond)
	e1:SetTarget(s.dirtg)
	e1:SetOperation(s.dirop)
	c:RegisterEffect(e1)
end
function s.dircond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN) and Duel.IsAbleToEnterBP()
		and not e:GetHandler():IsHasEffect(EFFECT_DIRECT_ATTACK)
		and Duel.GetMatchingGroupCount(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)==0
end
function s.dirtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
function s.dirop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)>0 then
		--Effect
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			--Direct attack
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3205)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DIRECT_ATTACK)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			c:RegisterEffect(e1)
			--Prevent non-Warriors from attacking
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_CANNOT_ATTACK)
			e2:SetProperty(EFFECT_FLAG_OATH)
			e2:SetTargetRange(LOCATION_MZONE,0)
			e2:SetTarget(s.ftarget)
			e2:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e2,tp)
		end
	end
end
function s.ftarget(e,c)
	return not c:IsRace(RACE_WARRIOR)
end