-- ふわんだりぃず×すのーる
-- Flundereeze x Snowl
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Can conduct 3 normal summons
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.trcon)
	e1:SetTarget(s.nstg)
	e1:SetOperation(s.nsop)
	c:RegisterEffect(e1)
	-- Piercing damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.trcon)
	c:RegisterEffect(e2)
	-- Flip opponent monsters face-down
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.fdcon)
	e3:SetCost(s.fdcost)
	e3:SetTarget(s.fdtg)
	e3:SetOperation(s.fdop)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e3)
end
function s.trcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TRIBUTE)
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=0
		local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_SET_SUMMON_COUNT_LIMIT)}
		for _,te in ipairs(ce) do
			ct=math.max(ct,te:GetValue())
		end
		return ct<3
	end
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(3)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.fdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp)
end
function s.fdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.fdfilter(c)
	return c:IsCanTurnSet() and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.fdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.fdfilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.fdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.fdfilter,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
