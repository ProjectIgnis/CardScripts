--海竜神－ネオダイダロス
--Ocean Dragon Lord - Neo-Daedalus
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Must be Special Summoned (from your hand) by Tributing 1 "Levia-Dragon - Daedalus"
	c:AddMustBeSpecialSummoned()
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(function(e,c)
		if c==nil then return true end
		local tp=c:GetControler()
		return Duel.CheckReleaseGroup(tp,Card.IsCode,1,false,1,true,c,tp,nil,false,nil,37721209)
	end)
	e0:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk,c)
		local g=Duel.SelectReleaseGroup(tp,Card.IsCode,1,1,false,true,true,c,nil,nil,false,nil,37721209)
		if g and #g>0 then
			e:SetLabelObject(g)
			return true
		end
		return false
	end)
	e0:SetOperation(function(e,tp,eg,ep,ev,re,r,rp,c)
		local g=e:GetLabelObject()
		if g and #g>0 then
			Duel.Release(g,REASON_COST)
		end
	end)
	c:RegisterEffect(e0)
	--You can send 1 face-up "Umi" you control to the GY; send all other cards on the field and all cards in both players' hands to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.tgcost)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
end
s.listed_names={37721209,CARD_UMI} --"Levia-Dragon - Daedalus"
function s.tgcostfilter(c,hc)
	return c:IsCode(CARD_UMI) and c:IsFaceup() and c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,0,LOCATION_HAND|LOCATION_ONFIELD,LOCATION_HAND|LOCATION_ONFIELD,1,Group.FromCards(c,hc))
end
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgcostfilter,tp,LOCATION_ONFIELD,0,1,nil,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgcostfilter,tp,LOCATION_ONFIELD,0,1,1,nil,c)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_HAND|LOCATION_ONFIELD,LOCATION_HAND|LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_HAND|LOCATION_ONFIELD)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local exc=c:IsRelateToEffect(e) and c or nil
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_HAND|LOCATION_ONFIELD,LOCATION_HAND|LOCATION_ONFIELD,exc)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end