--Master Magician's Incantation
--original script by Shad3
--Works perfectly for "EVENT_FREE_CHAIN" and "EVENT_CHAINING" spells only
local s,id=GetID()
function s.initial_effect(c)
	--Flag to avoid infinite loop
	s['no_react_ev']=true
	--Global check
	if not s['gl_chk'] then
		s['gl_chk']=true
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.flag_op)
		Duel.RegisterEffect(ge1,0)
	end
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.flag_op(e,tp,eg,ep,ev,re,r,rp)
	local ch=Duel.GetCurrentChain()
	s['cstore_'..ch]={eg,ep,ev,re,r,rp}
end
function s.hnd_fil(c,e,tp,eg,ep,ev,re,r,rp)
	if c:IsType(TYPE_SPELL) and not s['no_react_ev'] then
	local te=c:GetActivateEffect()
	if not te then return end
	local cd=te:GetCondition()
	local cs=te:GetCost()
	local tg=te:GetTarget()
	if te:GetCode()==EVENT_CHAINING then
		local ch=Duel.GetCurrentChain()-1
		if ch>0 then
			local i=s['cstore_'..ch]
			local neg,nep,nev,nre,nr,nrp=i[1],i[2],i[3],i[4],i[5]
			return (not cd or cd(te,tp,neg,nep,nev,nre,nr,nrp)) and
			(not cs or cs(te,tp,neg,nep,nev,nre,nr,nrp,0)) and
			(not tg or tg(te,tp,neg,nep,nev,nre,nr,nrp,0))
		end
		elseif te:GetCode()==EVENT_FREE_CHAIN then
			return (not cd or cd(te,tp,eg,ep,ev,re,r,rp)) and
			(not cs or cs(te,tp,eg,ep,ev,re,r,rp,0)) and
			(not tg or tg(te,tp,eg,ep,ev,re,r,rp,0))
		end
	end
	return false
end
function s.szo_fil(c,e,tp,eg,ep,ev,re,r,rp)
	return not c:IsFaceup() and s.hnd_fil(c,e,tp,eg,ep,ev,re,r,rp)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
	local loc=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then loc=loc-1 end
		if loc>0 then
			return Duel.IsExistingMatchingCard(s.szo_fil,tp,LOCATION_SZONE,0,1,e:GetHandler(),e,tp,eg,ep,ev,re,r,rp)
				or Duel.IsExistingMatchingCard(s.hnd_fil,tp,LOCATION_HAND,0,1,e:GetHandler(),e,tp,eg,ep,ev,re,r,rp)
		elseif loc==0 then
			return Duel.IsExistingMatchingCard(s.szo_fil,tp,LOCATION_SZONE,0,1,e:GetHandler(),e,tp,eg,ep,ev,re,r,rp)
		end
		return false
		end
	e:SetProperty(0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local og=Duel.GetMatchingGroup(s.szo_fil,tp,LOCATION_SZONE,0,e:GetHandler(),e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		og:Merge(Duel.GetMatchingGroup(s.hnd_fil,tp,LOCATION_HAND,0,e:GetHandler(),e,tp,eg,ep,ev,re,r,rp))
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(511005057,1))
	local tc=og:Select(tp,1,1,nil):GetFirst()
	if not tc then return end
	local te=tc:GetActivateEffect()
	local cs=te:GetCost()
	local tg=te:GetTarget()
	local op=te:GetOperation()
	local neg,nep,nev,nre,nr,nrp=eg,ep,ev,re,r,rp
	if te:GetCode()==EVENT_CHAINING then
		local ch=Duel.GetCurrentChain()-1
		local i=s['cstore_'..ch]
		neg,nep,nev,nre,nr,nrp=i[1],i[2],i[3],i[4],i[5]
	end
	Duel.ClearTargetCard()
	e:SetProperty(te:GetProperty())
	if tc:IsLocation(LOCATION_HAND) then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	else
		Duel.ChangePosition(tc,POS_FACEUP)
	end
	Duel.Hint(HINT_CARD,0,tc:GetOriginalCode())
	if not (tc:IsType(TYPE_SPELL) and tc:IsType(TYPE_CONTINUOUS+TYPE_EQUIP)) then tc:CancelToGrave(false) end
	if not tc:IsType(TYPE_SPELL) then return end
	tc:CreateEffectRelation(te)
	if cs then cs(te,tp,neg,nep,nev,nre,nr,nrp,1) end
	if tg then tg(te,tp,neg,nep,nev,nre,nr,nrp,1) end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g then
		local tgc=g:GetFirst()
		while tgc do
		  tgc:CreateEffectRelation(te)
		  tgc=g:GetNext()
		end
	end
	tc:SetStatus(STATUS_ACTIVATED,true)
	if op then op(te,tp,neg,nep,nev,nre,nr,nrp) end
	tc:ReleaseEffectRelation(te)
	if g then
		local tgc=g:GetFirst()
		while tgc do
		  tgc:ReleaseEffectRelation(te)
		  tgc=g:GetNext()
		end
	end
end