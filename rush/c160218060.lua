--スピード・スナイパー
--Speed Sniper
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon
	local params = {s.filter,s.mfilter,s.fextra,Fusion.ShuffleMaterial,nil,s.stage2}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e1:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsDefense(2300)
end
function s.mfilter(c)
	return c:IsLocation(LOCATION_GRAVE|LOCATION_MZONE) and c:IsRace(RACE_WARRIOR) and c:IsType(TYPE_EFFECT) and c:IsAbleToDeck()
end
function s.fextra(e,tp,mg)
	local c=e:GetHandler()
	local loc=LOCATION_MZONE
	if c:IsSummonPhaseMain() and c:IsStatus(STATUS_SPSUMMON_TURN) then loc=LOCATION_GRAVE|LOCATION_MZONE end
	return Duel.GetMatchingGroup(s.mfilter,tp,loc,0,nil)
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==0 then
		--Prevent non-Warriors from attacking
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_OATH)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(s.ftarget)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(aux.Stringid(id,1))
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetTargetRange(1,0)
		e2:SetValue(s.aclimit)
		e2:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.ftarget(e,c)
	return not c:IsRace(RACE_WARRIOR)
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(id)
end