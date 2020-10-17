--スプリガンズ・シップ エクスブロウラー
--Sprigguns Ship Exblower
--Scripted by DyXel

local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,nil,8,2,nil,nil,99)
	c:EnableReviveLimit()
	--Plus sign destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_ONFIELD)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--Banish itself
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.bancon)
	e2:SetTarget(s.bantg)
	e2:SetOperation(s.banop)
	c:RegisterEffect(e2)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():GetOverlayCount()>0 and Duel.GetMatchingGroupCount(aux.NOT(Card.IsLocation),tp,0,LOCATION_ONFIELD,nil,LOCATION_FZONE|LOCATION_PZONE)>0 end
end
--Get the bits of place denoted by loc and seq as well as its vertically and
--horizontally adjancent zones.
function s.adjzone(loc,seq)
	if loc==LOCATION_MZONE then
		if seq<5 then
			--Own zone and horizontally adjancent | Vertical adjancent zone
			return ((7<<(seq-1))&0x1F)|(1<<(seq+8))
		else
			--Own zone | vertical adjancent main monster zone
			return (1<<seq)|(2+(6*(seq-5)))
		end
	else --loc == LOCATION_SZONE
		--Own zone and horizontally adjancent | Vertical adjancent zone
		return ((7<<(seq+7))&0x1F00)|(1<<seq)
	end
end
--Get a group of cards from a location and sequence (and its adjancent zones)
--that is fetched from a set bit of a zone bitfield integer.
function s.groupfrombit(bit,p)
	local loc=(bit&0x7F>0) and LOCATION_MZONE or LOCATION_SZONE
	local seq=(loc==LOCATION_MZONE) and bit or bit>>8
	seq = math.floor(math.log(seq,2))
	local g=Group.CreateGroup()
	local function optadd(loc,seq)
		local c=Duel.GetFieldCard(p,loc,seq)
		if c then g:AddCard(c) end
	end
	optadd(loc,seq)
	if seq<=4 then --No EMZ
		if seq+1<=4 then optadd(loc,seq+1) end
		if seq-1>=0 then optadd(loc,seq-1) end
	end
	if loc==LOCATION_MZONE then
		if seq<5 then
			optadd(LOCATION_SZONE,seq)
			if seq==1 then optadd(LOCATION_MZONE,5) end
			if seq==3 then optadd(LOCATION_MZONE,6) end
		elseif seq==5 then
			optadd(LOCATION_MZONE,1)
		elseif seq==6 then
			optadd(LOCATION_MZONE,3)
		end
	else -- loc == LOCATION_SZONE
		optadd(LOCATION_MZONE,seq)
	end
	return g
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local filter=0
	for oc in aux.Next(Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)) do
		filter=filter|s.adjzone(oc:GetLocation(),oc:GetSequence())
	end
	local zone=Duel.SelectFieldZone(tp,1,0,LOCATION_ONFIELD,~filter<<16)
	Duel.Hint(HINT_ZONE,tp,zone)
	Duel.Hint(HINT_ZONE,1-tp,zone>>16)
	local sg=s.groupfrombit(zone>>16,1-tp):Select(tp,1,c:GetOverlayCount(),false)
	local sgc=#sg
	if c:RemoveOverlayCard(tp,sgc,sgc,REASON_EFFECT) then
		Duel.Destroy(sg,REASON_EFFECT|REASON_DESTROY)
	end
end
function s.bancon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.GetTurnPlayer()~=tp
		and (Duel.IsMainPhase() or Duel.IsBattlePhase())
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.Remove(c,c:GetPosition(),REASON_EFFECT+REASON_TEMPORARY) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(function(e)Duel.ReturnToField(e:GetLabelObject())end)
		Duel.RegisterEffect(e1,tp)
	end
end
