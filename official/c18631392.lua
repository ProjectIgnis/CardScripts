--マアト
--Ma'at
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:AddMustBeSpecialSummoned()
	--Must be Special Summoned (from your hand) by sending 1 LIGHT Dragon-Type monster and 1 LIGHT Fairy-Type monster you control to the Graveyard, and cannot be Special Summoned by other ways
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Once per turn: You can declare 3 card names; excavate the top 3 cards of your Deck, add any of them that you named to your hand, also send the remaining cards to the Graveyard
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.exctg)
	e3:SetOperation(s.excop)
	c:RegisterEffect(e3)
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:GetBinClassCount(Card.GetRace)==2
end
function s.spfilter(c,race)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY|RACE_DRAGON) and c:IsAbleToGraveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil)
	return aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,1,tp,HINTMSG_TOGRAVE)
	if #g>0 then
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
end
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3)
		and Duel.GetDecktopGroup(tp,3):IsExists(Card.IsAbleToHand,1,nil) end
	local codes={}
	for i=1,3 do
		table.insert(codes,Duel.AnnounceCard(tp,DF.IsMainDeckCard()))
	end
	e:GetChainData().announced_card=codes
end
function s.thfilter(c,...)
	return c:IsCode(...) and c:IsAbleToHand()
end
function s.excop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanDiscardDeck(tp,3) then return end
	local cd=e:GetChainData()
	Duel.ConfirmDecktop(tp,3)
	local g=Duel.GetDecktopGroup(tp,3)
	local hg,gg=g:Split(s.thfilter,nil,table.unpack(cd.announced_card))
	if #hg>0 then
		Duel.DisableShuffleCheck()
		Duel.SendtoHand(hg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,hg)
		Duel.ShuffleHand(tp)
	end
	if #gg>0 then
		Duel.DisableShuffleCheck()
		Duel.SendtoGrave(gg,REASON_EFFECT|REASON_EXCAVATE)
	end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		--This card's ATK and DEF each become equal to the number of cards added to your hand by this effect x 1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(#hg*1000)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		c:RegisterEffect(e2)
	end
end
