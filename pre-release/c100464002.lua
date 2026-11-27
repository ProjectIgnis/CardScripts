--暗黒海異
--Black Shasta
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If this card is in your hand and you control a Normal Monster or a Dinosaur monster: You can Special Summon this card.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--If this card is destroyed by battle or card effect and sent to the GY: You can equip this card to 1 face-up monster on the field as an Equip Spell with these effects.
	--● The equipped monster loses 2400 ATK.
	--● If the equipped monster has 2500 or more original ATK, neither player can activate its effects.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.eqcon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
function s.spconfilter(c)
	return (c:IsType(TYPE_NORMAL) or c:IsRace(RACE_DINOSAUR)) and c:IsFaceup()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE|REASON_EFFECT) and c:IsLocation(LOCATION_GRAVE)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:CheckUniqueOnField(tp)
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,tp,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local sc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
		if not sc then return end
		Duel.HintSelection(sc)
		if Duel.Equip(tp,c,sc) then
			--Equip this card to 1 face-up monster on the field as an Equip Spell with these effects
			local e0=Effect.CreateEffect(c)
			e0:SetType(EFFECT_TYPE_SINGLE)
			e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e0:SetCode(EFFECT_EQUIP_LIMIT)
			e0:SetValue(function(e,c) return c==sc end)
			e0:SetReset(RESET_EVENT|RESETS_STANDARD)
			c:RegisterEffect(e0)
			--● The equipped monster loses 2400 ATK
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_EQUIP)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-2400)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			c:RegisterEffect(e1)
			--● If the equipped monster has 2500 or more original ATK, neither player can activate its effects
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e2:SetCode(EFFECT_CANNOT_TRIGGER)
			e2:SetCondition(function(e)
				return sc:GetBaseAttack()>=2500
			end)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			c:RegisterEffect(e2)
		end
	end
end