--テンプレート・スキッパー
--Template Skipper
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card (from your hand) to your zone a Cyberse Link Monster points to
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP,0)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetValue(function(e,c) return 0,aux.GetMMZonesPointedTo(c:GetControler(),aux.FilterBoolFunction(Card.IsRace,RACE_CYBERSE)) end)
	c:RegisterEffect(e1)
	--Banish 1 Cyberse monster from your hand or GY, and if you do, this card can be treated as Link Material with the same name this turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.rmvtg)
	e2:SetOperation(s.rmvop)
	c:RegisterEffect(e2)
end
function s.cybersefilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsAbleToRemove() and not c:IsCode(id)
end
function s.rmvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cybersefilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.cybersefilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
		--This card can be treated as Link Material with the same name as the banished monster if used for a Link Summon this turn
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_ADD_CODE)
		e1:SetOperation(function(scard,sumtype,tp) return sumtype&(SUMMON_TYPE_LINK|MATERIAL_LINK)==SUMMON_TYPE_LINK|MATERIAL_LINK end)
		e1:SetValue(tc:GetCode())
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
	end
end