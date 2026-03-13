--光の創造神 ホルアクティ
--Holactie the Creator of Light
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:AddMustBeSpecialSummoned()
	--Must be Special Summoned (from your hand) by Tributing 3 monsters whose original names are "Slifer the Sky Dragon", "Obelisk the Tormentor", and "The Winged Dragon of Ra"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.selfspcon)
	e1:SetTarget(s.selfsptg)
	e1:SetOperation(s.selfspop)
	c:RegisterEffect(e1)
	--This card's Special Summon cannot be negated
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	c:RegisterEffect(e2)
	--The player that Special Summons this card wins the Duel
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(function(e) Duel.Win(e:GetHandler():GetSummonPlayer(),WIN_REASON_CREATORGOD) end)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_SLIFER,CARD_OBELISK,CARD_RA}
function s.rescon(sg,e,tp,mg)
	return Duel.GetMZoneCount(tp,sg)>0 and sg:GetClassCount(Card.GetOriginalCodeRule)==3
end
function s.selfspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetReleaseGroup(tp):Match(Card.IsOriginalCodeRule,nil,CARD_SLIFER,CARD_OBELISK,CARD_RA)
	return #g>=3 and aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,0)
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetReleaseGroup(tp):Match(Card.IsOriginalCodeRule,nil,CARD_SLIFER,CARD_OBELISK,CARD_RA)
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,1,tp,HINTMSG_RELEASE,nil,nil,true)
	if #sg==3 then
		e:SetLabelObject(sg)
		return true
	end
	return false
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if g then
		Duel.Release(g,REASON_COST)
	end
end