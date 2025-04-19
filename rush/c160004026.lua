--旋楽姫ヌンチャクラリネット
--Nuncharinet the Music Princess
local s,id=GetID()
function s.initial_effect(c)
	--ATK increase
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
function s.filter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil)
		and Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_MZONE,0,1,nil)>0
	end
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsNotMaximumModeSide()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.DiscardDeck(tp,1,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	local ct=g:GetFirst()
	if ct then
		--If it was a monster, make 1 warrior monster gain ATK equal to sent monster's level x 300 and take damage equal to that amount
		if ct:IsMonster() and ct:IsRace(RACE_WARRIOR) and ct:IsAttribute(ATTRIBUTE_WIND) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
			local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
			Duel.HintSelection(Group.FromCards(tc))
			local atk=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_MZONE,0,nil)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
			e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
			e1:SetValue(atk*-500)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2)
		end
	end
end
