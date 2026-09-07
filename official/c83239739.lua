--オイスターマイスター
--Oyster Meister
local s,id=GetID()
local TOKEN_OYSTER=id+1
function s.initial_effect(c)
	--If this card is sent from the field to the GY, except when destroyed by battle: Special Summon 1 "Oyster Token" (Fish/WATER/Level 1/ATK 0/DEF 0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.tokencon)
	e1:SetTarget(s.tokentg)
	e1:SetOperation(s.tokenop)
	c:RegisterEffect(e1)
end
s.listed_names={TOKEN_OYSTER}
function s.tokencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and not c:IsReason(REASON_BATTLE)
end
function s.tokentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tokenop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_OYSTER,0,TYPES_TOKEN,0,0,1,RACE_FISH,ATTRIBUTE_WATER) then
		local token=Duel.CreateToken(tp,TOKEN_OYSTER)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end