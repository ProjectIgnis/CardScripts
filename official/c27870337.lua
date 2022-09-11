--ドレミコード・エレガンス
--Doremichord Elegance
--Scripted by Hel
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
end
s.listed_series={0x164}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1 = s.dtoptg(e,tp,eg,ep,ev,re,r,rp,0)
	local b2 = s.htoetg(e,tp,eg,ep,ev,re,r,rp,0)
	local b3 = s.drawtg(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 or b3 end
	local ops={}
	local opval={}
	local off=1
	if b1 then
		ops[off]=aux.Stringid(id,0)
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(id,1)
		opval[off-1]=2
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(id,2)
		opval[off-1]=3
		off=off+1
	end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	local sel=opval[op]
	if sel==1 then
		e:SetOperation(s.dtopop)
	elseif sel==2 then
		e:SetOperation(s.htoeop)
	elseif sel==3 then
		e:SetCategory(CATEGORY_DRAW)
		e:SetOperation(s.drawop)
		s.drawtg(e,tp,eg,ep,ev,re,r,rp,1)
	else
		e:SetCategory(0)
		e:SetOperation(nil)
	end
end
function s.filter(c)
	return c:IsSetCard(0x164) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden() 
end
function s.dtoptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
function s.dtopop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function s.check(sg,e,tp,mg)
	return sg:IsExists(Card.IsEvenScale,1,nil) and sg:IsExists(Card.IsOddScale,1,nil)
end
function s.htoetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) 
		and aux.SelectUnselectGroup(g,e,tp,2,2,s.check,0,tp,nil) 
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) and Duel.CheckLocation(tp,LOCATION_PZONE,1))
	end
end
function s.move_to_pendulum_zone(c,tp,e)
	if not c or not Duel.CheckPendulumZones(tp) then return end
	Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
end
function s.htoeop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil)
	local g2=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SendtoExtraP(g,tp,REASON_EFFECT)>0 then
		local sg=aux.SelectUnselectGroup(g2,e,tp,2,2,s.check,1,tp,HINTMSG_TOFIELD)
		if #sg==2 then
			Duel.BreakEffect()
			s.move_to_pendulum_zone(sg:GetFirst(),tp,e)
			s.move_to_pendulum_zone(sg:GetNext(),tp,e)
		end
	end
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.NOT(Card.IsForbidden),tp,LOCATION_PZONE,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.check,0,tp,nil) and Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local g=Duel.GetMatchingGroup(aux.NOT(Card.IsForbidden),tp,LOCATION_PZONE,0,nil)
	if aux.SelectUnselectGroup(g,e,tp,2,2,s.check,0,tp,nil) and Duel.SendtoExtraP(g,tp,REASON_EFFECT)>0
		and Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)==2 then
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
