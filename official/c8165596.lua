--Ｎｏ．９０ 銀河眼の光子卿
--Number 90: Galaxy-Eyes Photon Lord
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 8 monsters
	Xyz.AddProcedure(c,nil,8,2)
	--If this card has a "Photon" card as material, it cannot be destroyed by card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,SET_PHOTON) end)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Negate an opponent's monster effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp,chk) return rp==1-tp and re:IsMonsterEffect() and Duel.IsChainDisablable(ev) end)
	e2:SetCost(Cost.Detach(1,1,function(e,og) e:SetLabel(og:GetFirst():IsSetCard(SET_GALAXY) and 1 or 0) end))
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	--Take 1 "Photon" or "Galaxy" card from your Deck, and either add it to your hand or attach it to this card as material
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e3:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e3:SetTarget(s.thmattg)
	e3:SetOperation(s.thmatop)
	c:RegisterEffect(e3)
end
s.xyz_number=90
s.listed_series={SET_PHOTON,SET_GALAXY}
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rc=re:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,tp,0)
	if rc:IsDestructable() and rc:IsRelateToEffect(re) and e:GetLabel()==1 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) and e:GetLabel()==1 then
		Duel.BreakEffect()
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function s.thmatfilter(c,hc,tp,relation_chk)
	return c:IsSetCard({SET_PHOTON,SET_GALAXY}) and (c:IsAbleToHand() or (relation_chk and c:IsCanBeXyzMaterial(hc,tp,REASON_EFFECT)))
end
function s.thmattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thmatfilter,tp,LOCATION_DECK,0,1,nil,e:GetHandler(),tp,true) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thmatop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local relation_chk=c:IsRelateToEffect(e)
	local desc=relation_chk and aux.Stringid(id,2) or HINTMSG_ATOHAND
	Duel.Hint(HINT_SELECTMSG,tp,desc)
	local sc=Duel.SelectMatchingCard(tp,s.thmatfilter,tp,LOCATION_DECK,0,1,1,nil,c,tp,relation_chk):GetFirst()
	if not sc then return end
	aux.ToHandOrElse(sc,tp,
		function() return relation_chk and sc:IsCanBeXyzMaterial(c,tp,REASON_EFFECT) end,
		function() Duel.Overlay(c,sc) end,
		aux.Stringid(id,3)
	)
end
