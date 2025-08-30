--諧謔のコスモス姫
--Princess Cosmos the Trickster
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local params={aux.FilterBoolFunction(s.fusfilter),s.mfilter,s.fextra,Fusion.ShuffleMaterial,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,9}
	local params2={aux.FilterBoolFunction(s.fusfilter),s.mfilter,s.fextra,Fusion.ShuffleMaterial,nil,nil,nil,nil,nil,nil,nil,nil,nil,9}
	--Destroy up to 3 monsters on your field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation(Fusion.SummonEffTG(table.unpack(params)),Fusion.SummonEffOP(table.unpack(params2))))
	c:RegisterEffect(e1)
end
function s.fusfilter(c)
	return c:IsRace(RACE_GALAXY) and c:IsDefense(1900,2600)
end
function s.mfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsRace(RACE_GALAXY) and c:IsAbleToDeck()
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonPhaseMain() and c:IsStatus(STATUS_SUMMON_TURN+STATUS_SPSUMMON_TURN)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #dg>0 end
end
function s.operation(fustg,fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		--Effect
		local dg=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_MZONE,0,nil)
		if #dg>0 then
			local sg=dg:Select(tp,1,3,nil)
			Duel.HintSelection(sg)
			if Duel.Destroy(sg,REASON_EFFECT)>0 and fustg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.BreakEffect()
				fusop(e,tp,eg,ep,ev,re,r,rp)
			end
		end
		--Cannot activate the effect of "Princess Cosmos the Trickster"
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(id)
end