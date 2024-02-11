--トイ・ボックス
--Toy Box
--scripted by Naim
local s,id=GetID()
local CARD_TOY_BOX=id
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Destroy an opponent's attacking monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp) return Duel.GetAttacker():IsControler(1-tp) end)
	e2:SetCost(s.mondescost)
	e2:SetTarget(s.mondestg)
	e2:SetOperation(s.mondesop)
	c:RegisterEffect(e2)
	--Activate 1 of these effects
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.efftg)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_TOY}
local LOCATIONS_HAND_DECK_MZONE_GRAVE=LOCATION_HAND|LOCATION_DECK|LOCATION_MZONE|LOCATION_GRAVE
function s.cstfilter(c)
	return c:IsFacedown() and c:IsAbleToGraveAsCost()
end
function s.mondescost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cstfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cstfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.mondestg(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttacker()
	if chk==0 then return at:IsRelateToBattle() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,at,1,0,0)
end
function s.mondesop(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	if at:IsRelateToBattle() and at:IsControler(1-tp) then
		Duel.Destroy(at,REASON_EFFECT)
	end
end
function s.setfilter(c)
	local set_eff=c:IsHasEffect(EFFECT_MONSTER_SSET)
	return c:IsOriginalSetCard(SET_TOY) and c:IsMonster() and set_eff and set_eff:GetValue()&TYPE_SPELL>0
		and c:IsSSetable() and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE))
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_STZONE,0,nil)
	local b1=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATIONS_HAND_DECK_MZONE_GRAVE,0,1,nil)
	local b2=#g>0
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(0)
	elseif op==2 then
		e:SetCategory(CATEGORY_DESTROY)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Set up to 2 "Toy" monsters in your Spell & Trap Zone as Spells
		local ft=math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),2)
		if ft==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATIONS_HAND_DECK_MZONE_GRAVE,0,1,ft,nil)
		if #g>0 then
			Duel.SSet(tp,g)
		end
	elseif op==2 then
		--Destroy up to 2 cards in your Spell & Trap Zone
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_STZONE,0,1,2,nil)
		if #g>0 then
			Duel.HintSelection(g,true)
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end