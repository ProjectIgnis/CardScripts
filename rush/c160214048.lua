--古代の機械猟犬
--Ancient Gear Hunting Hound (Rush)
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Inflict 600 damage and Fusion Summon
	local params = {s.fusfilter,s.matfilter}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation(Fusion.SummonEffTG(table.unpack(params)),Fusion.SummonEffOP(table.unpack(params))))
	c:RegisterEffect(e1)
end
function s.fusfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsDefense(c:GetAttack())
end
function s.matfilter(c)
	return c:IsLocation(LOCATION_HAND|LOCATION_MZONE) and c:IsType(TYPE_EFFECT) and c:IsAbleToGrave()
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and c:IsStatus(STATUS_SUMMON_TURN)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(600)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
function s.operation(fustg,fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		--Effect
		local p,val=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		if Duel.Damage(p,val,REASON_EFFECT)>0 and fustg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			fusop(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end