--妖精霊クリボン
--Kuribon the Fairy Spirit
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card from your hand, and if you do, it is treated as a Tuner
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--If another "Ancient Fairy Dragon", or monster(s) that mentions it, that you control would be destroyed by card effect, you can return this card from the field to the hand instead
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.reptg)
	e2:SetValue(function(e,c) return s.repfilter(c,e:GetHandlerPlayer()) and c~=e:GetHandler() end)
	e2:SetOperation(function(e) Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT|REASON_REPLACE) end)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_ANCIENT_FAIRY_DRAGON}
function s.spconfilter(c)
	return c:IsFaceup() and (c:IsCode(CARD_ANCIENT_FAIRY_DRAGON)
		or (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_BEAST|RACE_PLANT|RACE_FAIRY) and c:IsMonster()))
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		--It is treated as a Tuner
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end
function s.repfilter(c,tp)
	return (c:IsCode(CARD_ANCIENT_FAIRY_DRAGON) or (c:ListsCode(CARD_ANCIENT_FAIRY_DRAGON) and c:IsMonster())) 
		and c:IsControler(tp) and c:IsFaceup() and c:IsOnField()
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() and not eg:IsContains(c) and eg:IsExists(s.repfilter,1,c,tp) end
	return Duel.SelectEffectYesNo(tp,c,96)
end