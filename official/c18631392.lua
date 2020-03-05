--マアト
--Ma'at
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--announce 3 cards
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.anctg)
	c:RegisterEffect(e3)
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:IsExists(s.atchk1,1,nil,sg)
end
function s.atchk1(c,sg)
	return c:IsRace(RACE_FAIRY) and sg:FilterCount(Card.IsRace,c,RACE_DRAGON)==1
end
function s.spfilter(c,rac)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(rac) and c:IsAbleToGraveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil,RACE_FAIRY)
	local rg2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil,RACE_DRAGON)
	local rg=rg1:Clone()
	rg:Merge(rg2)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and #rg1>0 and #rg2>0
		and aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil,RACE_FAIRY+RACE_DRAGON)
	local g=aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,1,tp,HINTMSG_TOGRAVE)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
end
function s.anctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if not Duel.IsPlayerCanDiscardDeck(tp,3) then return false end
		local g=Duel.GetDecktopGroup(tp,3)
		return g:FilterCount(Card.IsAbleToHand,nil)>0
	end
	s.announce_filter={TYPE_EXTRA,OPCODE_ISTYPE,OPCODE_NOT}
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac1=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac2=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac3=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
	e:SetOperation(s.retop(ac1,ac2,ac3))
end
function s.hfilter(c,code1,code2,code3)
	return c:IsCode(code1,code2,code3) and c:IsAbleToHand()
end
function s.retop(code1,code2,code3)
	return
		function (e,tp,eg,ep,ev,re,r,rp)
			if not Duel.IsPlayerCanDiscardDeck(tp,3) then return end
			local c=e:GetHandler()
			Duel.ConfirmDecktop(tp,3)
			local g=Duel.GetDecktopGroup(tp,3)
			local hg=g:Filter(s.hfilter,nil,code1,code2,code3)
			g:Sub(hg)
			if #hg~=0 then
				Duel.DisableShuffleCheck()
				Duel.SendtoHand(hg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,hg)
				Duel.ShuffleHand(tp)
			end
			if #g~=0 then
				Duel.DisableShuffleCheck()
				Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
			end
			if c:IsRelateToEffect(e) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_ATTACK_FINAL)
				e1:SetValue(#hg*1000)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
				c:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
				c:RegisterEffect(e2)
			end
		end
end
