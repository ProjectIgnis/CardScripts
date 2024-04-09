--スプリガンズ・シップ エクスブロウラー
--Springans Ship - Exblowrer
--Scripted by DyXel
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon
	Xyz.AddProcedure(c,nil,8,2,nil,nil,Xyz.InfiniteMats)
	--Destroy cards adjacent to the selected zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--Banish itself
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMING_BATTLE_START|TIMING_BATTLE_END)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.bancon)
	e2:SetTarget(s.bantg)
	e2:SetOperation(s.banop)
	c:RegisterEffect(e2)
end
--Get the bits of place denoted by loc and seq as well as its vertically and
--horizontally adjancent zones.
local function adjzone(loc,seq)
	if loc==LOCATION_MZONE then
		if seq<5 then
			--Own zone and horizontally adjancent | Vertical adjancent zone
			return ((7<<(seq-1))&ZONES_MMZ)|(1<<(seq+8))
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
local function groupfrombit(bit,p)
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
function s.filter(c)
	return not c:IsLocation(LOCATION_FZONE) and not (Duel.IsDuelType(DUEL_SEPARATE_PZONE) and c:IsLocation(LOCATION_PZONE))
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return e:GetHandler():GetOverlayCount()>0 and #g>0 end
	local filter=0
	for oc in g:Iter() do
		filter=filter|adjzone(oc:GetLocation(),oc:GetSequence())
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local zone=Duel.SelectFieldZone(tp,1,0,LOCATION_ONFIELD,~filter<<16)
	Duel.Hint(HINT_ZONE,tp,zone)
	Duel.Hint(HINT_ZONE,1-tp,zone>>16)
	e:SetLabel(zone)
	local sg=groupfrombit(zone>>16,1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=groupfrombit(e:GetLabel()>>16,1-tp)
	if #g==0 or c:GetOverlayCount()==0 or c:RemoveOverlayCard(tp,1,#g,REASON_EFFECT)<0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg=g:Select(tp,1,#Duel.GetOperatedGroup(),false)
	if #sg>0 then
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
function s.bancon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.IsTurnPlayer(1-tp)
		and (Duel.IsMainPhase() or Duel.IsBattlePhase())
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		Duel.Remove(c,POS_FACEUP,REASON_EFFECT|REASON_TEMPORARY)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE|PHASE_END)
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
