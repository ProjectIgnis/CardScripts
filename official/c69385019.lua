--皇たる水精鱗－ネプトアビス
--Mermail King - Neptabyss
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2+ monsters, including a Fish, Sea Serpent, or Aqua monster
	Link.AddProcedure(c,nil,2,3,s.matcheck)
	--Your opponent cannot target WATER monsters this card points to with card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(function(e,c) return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsAttribute(ATTRIBUTE_WATER) end)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--Add to your hand, or equip to this card, 1 "Abyss-" Equip Spell from your Deck or GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.eqcon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	--Add 1 "Atlantean" or "Mermail" monster from your Deck to your hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp and e:GetHandler():IsPreviousControler(tp) end)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ABYSS,SET_ATLANTEAN,SET_MERMAIL}
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsRace,1,nil,RACE_FISH|RACE_SEASERPENT|RACE_AQUA,lc,sumtype,tp)
end
function s.eqconfilter(c)
	return c:IsReason(REASON_COST) and c:IsAttribute(ATTRIBUTE_WATER) and (not c:IsPreviousLocation(LOCATION_MZONE) or c:IsPreviousAttributeOnField(ATTRIBUTE_WATER))
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActivated() and eg:IsExists(s.eqconfilter,1,nil)
end
function s.eqfilter(c,tp,stzone_check,ec)
	return c:IsSetCard(SET_ABYSS) and c:IsEquipSpell() and (c:IsAbleToHand()
		or (stzone_check and ec and c:CheckEquipTarget(ec) and c:CheckUniqueOnField(tp) and not c:IsForbidden()))
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,tp,Duel.GetLocationCount(tp,LOCATION_SZONE)>0,e:GetHandler()) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsFaceup()) then c=nil end
	local stzone_check=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,tp,stzone_check,c):GetFirst()
	if sc then
		aux.ToHandOrElse(sc,tp,
			function()
				return stzone_check and c and sc:CheckEquipTarget(c) and sc:CheckUniqueOnField(tp) and not sc:IsForbidden()
			end,
			function()
				Duel.Equip(tp,sc,c)
			end,
			aux.Stringid(id,3)
		)
	end
end
function s.thfilter(c)
	return c:IsSetCard({SET_ATLANTEAN,SET_MERMAIL}) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end