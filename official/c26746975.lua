--闇の守護神－ダーク・ガーディアン
--Dark Guardian
--scripted by pyrQ
local CARD_DARK_ELEMENT=53194323
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Must be Special Summoned with "Dark Element" or its own procedure
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	--Special Summon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCondition(s.spproccon)
	e1:SetTarget(s.spproctg)
	e1:SetOperation(s.spprocop)
	c:RegisterEffect(e1)
	--Cannot be destroyed by battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Register if it's Special Summoned with "Dark Element"
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	--Unaffected by other monsters' effects and your opponent's activated Spell effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	e4:SetValue(s.immvalue)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_SANGA_OF_THE_THUNDER,CARD_KAZEJIN,CARD_SUIJIN,CARD_DARK_ELEMENT}
function s.tdfilter(c)
	return c:IsCode(CARDS_SANGA_KAZEJIN_SUIJIN) and c:IsAbleToDeckAsCost() and (c:IsFaceup() or c:IsLocation(LOCATION_HAND|LOCATION_GRAVE))
end
function s.rescon(sg,e,tp,mg)
	return Duel.GetMZoneCount(tp,sg)>0
		and sg:IsExists(Card.IsCode,1,nil,CARD_SANGA_OF_THE_THUNDER)
		and sg:IsExists(Card.IsCode,1,nil,CARD_KAZEJIN)
		and sg:IsExists(Card.IsCode,1,nil,CARD_SUIJIN)
end
function s.spproccon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_ONFIELD|LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,e:GetHandler())
	return aux.SelectUnselectGroup(rg,e,tp,3,3,s.rescon,0)
end
function s.spproctg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_ONFIELD|LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,e:GetHandler())
	local g=aux.SelectUnselectGroup(rg,e,tp,3,3,s.rescon,1,tp,HINTMSG_TODECK,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spprocop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.HintSelection(g,true)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	g:DeleteGroup()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsCode(CARD_DARK_ELEMENT) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~RESET_TEMP_REMOVE,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
	end
end
function s.immvalue(e,te)
	return (te:IsMonsterEffect() and te:GetOwner()~=e:GetOwner())
		or (te:IsActivated() and te:IsSpellEffect() and te:GetOwnerPlayer()~=e:GetHandlerPlayer())
end