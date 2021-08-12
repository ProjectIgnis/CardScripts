-- 運命の旅路
-- Journey of Destiny
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- Prevent battle destruction once
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCountLimit(1)
	e2:SetValue(function(_,_,r) return r&REASON_BATTLE==REASON_BATTLE end)
	e2:SetTarget(function(_,c) return c:GetEquipCount()>0 end)
	c:RegisterEffect(e2)
	-- Search monster that lists "Brave Token"
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.mthtg)
	e3:SetOperation(s.mthop)
	c:RegisterEffect(e3)
	-- Search Equip Spell that lists "Brave Token"
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id+100)
	e4:SetTarget(s.sthtg)
	e4:SetOperation(s.sthop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
s.listed_names={TOKEN_BRAVE}
function s.mthfilter(c)
	return c:IsMonster() and aux.IsCodeListed(c,TOKEN_BRAVE) and c:IsAbleToHand()
end
function s.mthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.mthfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,tp,1)
end
function s.mthop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.mthfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT)
	end
end
function s.bravefilter(c,ec)
	return c:IsFaceup() and c:IsCode(TOKEN_BRAVE) and ec:CheckEquipTarget(c)
end
function s.eqfilter(c,tp)
	return c:CheckUniqueOnField(tp) and not c:IsForbidden() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.bravefilter,tp,LOCATION_MZONE,0,1,nil,c)
end
function s.sthfilter(c,tp)
	return c:IsType(TYPE_EQUIP) and aux.IsCodeListed(c,TOKEN_BRAVE)
		and (c:IsAbleToHand() or s.eqfilter(c,tp))
end
function s.sthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sthfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.sthop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local eqc=Duel.SelectMatchingCard(tp,s.sthfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if not eqc then return end
	aux.ToHandOrElse(eqc,tp,
		function(eqc) return s.eqfilter(eqc,tp) end,
		function(eqc)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local g=Duel.SelectMatchingCard(tp,s.bravefilter,tp,LOCATION_MZONE,0,1,1,nil,eqc)
			Duel.HintSelection(g,true)
			local tc=g:GetFirst()
			if tc then Duel.Equip(tp,eqc,tc) end
		end,
		aux.Stringid(id,2)
	)
end