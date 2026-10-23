--美ノ里のマロンキャット
--Marron Cat of Minori
--scripted by Cybercatman
local s,id=GetID()
local CARD_BLAZING_CHESTNUT=160003044
function s.initial_effect(c)
	--Excavate the top 3 cards of your Deck. Place the excavated cards on top of your Deck in any order.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_BLAZING_CHESTNUT,id}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_GRAVE)
end
function s.filter(c)
	return c:IsCode(CARD_BLAZING_CHESTNUT) and c:IsSSetable()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Effect
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	Duel.SortDecktop(tp,tp,3)
	if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local free_zones=math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),2)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,1,free_zones,nil,e,tp)
		if #g>0 and Duel.SSet(tp,g)>0 then
			--This turn, you take no damage from the effect of "Blazing Chestnut"
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CHANGE_DAMAGE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetValue(s.damval)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
			e2:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e2,tp)
			--For rest of this turn, you cannot activate the effect of "Marron Cat of Minori"
			local e3=Effect.CreateEffect(c)
			e3:SetDescription(aux.Stringid(id,2))
			e3:SetType(EFFECT_TYPE_FIELD)
			e3:SetCode(EFFECT_CANNOT_ACTIVATE)
			e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e3:SetTargetRange(1,0)
			e3:SetValue(s.aclimit)
			e3:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e3,tp)
		end
	end
end
function s.damval(e,re,val,r,rp,rc)
	if (r&REASON_EFFECT)>0 and re:GetHandler():IsCode(CARD_BLAZING_CHESTNUT) then
		return 0
	else
		return val
	end
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(id)
end