--プロキシー・ホース
--Proxy Horse
--Scripted by the Razgriz and Cybercatman
local s,id=GetID()
function s.initial_effect(c)
	--Extra Link Material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_EXTRA_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetOperation(s.extracon)
	e1:SetValue(s.extraval)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetTarget(s.eftg)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--Return Link monsters to Extra Deck
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(s.tecon)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.tetg)
	e3:SetOperation(s.teop)
	c:RegisterEffect(e3)
	aux.GlobalCheck(s,function()
		s.flagmap={}
	end)
end
function s.eftg(e,c)
	return c:IsRace(RACE_CYBERSE) and c:IsCanBeLinkMaterial()
end
function s.extrafilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
function s.extracon(c,e,tp,sg,mg,lc,og,chk)
	local ct=sg:FilterCount(s.flagcheck,nil)
	return ct==0 or ((sg+mg):Filter(s.extrafilter,nil,e:GetHandlerPlayer()):IsExists(Card.IsCode,1,og,id) and ct<2)
end
function s.flagcheck(c)
	return c:GetFlagEffect(id)>0
end
function s.extraval(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or not sc:IsRace(RACE_CYBERSE) or Duel.GetFlagEffect(tp,id)>0 then
			return Group.CreateGroup()
		else
			s.flagmap[c]=c:RegisterFlagEffect(id,0,0,1)
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK and #sg>0 and Duel.GetFlagEffect(tp,id)==0 then
			Duel.Hint(HINT_CARD,tp,id)
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
	elseif chk==2 then
		if s.flagmap[c] then
			s.flagmap[c]:Reset()
			s.flagmap[c]=nil
		end
	end
end
function s.tefilter1(c)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK) and Duel.IsExistingTarget(s.tefilter2,0,LOCATION_GRAVE,0,1,c)
end
function s.tefilter2(c)
	return c:IsType(TYPE_LINK)
end
function s.tecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.tefilter1,tp,LOCATION_GRAVE,0,1,nil) and Duel.GetTurnPlayer()==tp
end
function s.tetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.tefilter1,tp,LOCATION_GRAVE,0,1,nil) and Duel.IsExistingTarget(s.tefilter2,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g1=Duel.SelectTarget(tp,s.tefilter1,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g2=Duel.SelectTarget(tp,s.tefilter2,tp,LOCATION_GRAVE,0,1,1,g1:GetFirst())
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,2,0,0)
end
function s.teop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
