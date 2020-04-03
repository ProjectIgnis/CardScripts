--concentration duel
local s,id=GetID()
function s.initial_effect(c)
	--protection
	local ea=Effect.CreateEffect(c)
	ea:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	ea:SetType(EFFECT_TYPE_SINGLE)
	ea:SetCode(EFFECT_CANNOT_TO_GRAVE)
	c:RegisterEffect(ea)
	local eb=ea:Clone()
	eb:SetCode(EFFECT_CANNOT_TO_HAND)
	c:RegisterEffect(eb)
	local ec=ea:Clone()
	ec:SetCode(EFFECT_CANNOT_TO_DECK) 
	c:RegisterEffect(ec)
	local ed=ea:Clone()
	ed:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	c:RegisterEffect(ed)
	--clean forbidden love
	local e0=Effect.CreateEffect(c) --turn end
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetRange(LOCATION_REMOVED)
	e0:SetCode(EVENT_TURN_END)
	e0:SetCountLimit(1)
	e0:SetOperation(s.cfl)
	c:RegisterEffect(e0)
	local e0a=e0:Clone() --when sent to deck
	e0a:SetCode(EVENT_TO_DECK)
	e0a:SetCondition(s.cflcon)
	c:RegisterEffect(e0a)
	--remove
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e0b:SetCode(EVENT_TO_HAND)
	e0b:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e0b:SetRange(LOCATION_REMOVED)
	e0b:SetTarget(s.damtg)
	e0b:SetOperation(s.damop)
	c:RegisterEffect(e0b)
	--active
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetCountLimit(1)
	e1:SetCondition(s.activecondition)
	e1:SetOperation(s.activeoperation)
	Duel.RegisterEffect(e1,0)
	--skip draw phase
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SKIP_DP)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
	--declare a normal summon or set
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_DISABLE_CHAIN)
	e3:SetDescription(1050)
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1)
	e3:SetCondition(s.normalsetcondition)
	e3:SetTarget(s.normalsettarget)
	e3:SetOperation(s.normalsetoperation)
	c:RegisterEffect(e3)
	--declare a spell activation
	local e4=Effect.CreateEffect(c)
	e4:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_DISABLE_CHAIN)
	e4:SetDescription(1051)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_REMOVED)
	e4:SetCountLimit(1)
	e4:SetTarget(s.spelltarget)
	e4:SetOperation(s.spelloperation)
	c:RegisterEffect(e4)
	--declare a trap activation
	local e5=Effect.CreateEffect(c)
	e5:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_DISABLE_CHAIN)
	e5:SetDescription(1052)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_REMOVED)
	e5:SetCountLimit(1)
	e5:SetTarget(s.traptarget)
	e5:SetOperation(s.trapoperation)
	c:RegisterEffect(e5)
end
forbidden={}
forbidden[0]={}
forbidden[1]={}
function s.cflcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler()~=e:GetHandler()
end
function s.cfl(e,tp,eg,ep,ev,re,r,rp)
	forbidden[tp]={}
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re and re:GetHandler()~=e:GetHandler() and not re:GetHandler():IsCode(id) end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local sg=eg
	if #sg>0 then
		Duel.SendtoDeck(sg,nil,0,REASON_RULE)
		if sg:IsExists(Card.IsControler,1,nil,tp) then
			Duel.ShuffleDeck(tp)
			forbidden[tp]={}
		end
	end
end
--active condition+operation
function s.activecondition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()==1
end
function s.activeoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_CARD,0,id)
	if not Duel.SelectYesNo(1-tp,aux.Stringid(4007,1)) or not Duel.SelectYesNo(tp,aux.Stringid(4007,1)) then
		local sg=Duel.GetMatchingGroup(Card.IsCode,tp,0x7f,0x7f,nil,id)
		Duel.SendtoDeck(sg,nil,-2,REASON_RULE)
		return
	end
	--place a card into opponent removed zone and you removed zone
	local tc=Duel.CreateToken(1-tp,id)
	Duel.Remove(tc,POS_FACEUP,REASON_RULE)
	Duel.Remove(c,POS_FACEUP,REASON_RULE)
	local hand1=Duel.GetMatchingGroup(Card.GetControler,tp,LOCATION_HAND,0,nil)
	Duel.SendtoDeck(hand1,tp,0,REASON_RULE)
	local hand2=Duel.GetMatchingGroup(Card.GetControler,tp,0,LOCATION_HAND,nil)
	Duel.SendtoDeck(hand2,1-tp,0,REASON_RULE)
	--if duel is using obsolete ruling change the draw count to 0 to avoid player from draw the first card.
	if Duel.IsDuelType(DUEL_OBSOLETE_RULING) then
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetTargetRange(1,1)
		e1:SetValue(0)
		Duel.RegisterEffect(e1,tp)
	end
end
--normal/set
function s.normalsetcondition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
function s.normalsettarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetChainLimit(s.nl)
end
function s.nl(e,tp,eg,ep,ev,re,r,rp)
	return false
end
function s.normalsetoperation(e,tp,eg,ep,ev,re,r,rp)
	local n=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local r={}
	for i=1,n do
		if not forbidden[tp][i] then table.insert(r,i) end
	end
	local an=Duel.AnnounceNumber(tp,table.unpack(r))-1
	local c=Duel.GetFieldCard(tp,LOCATION_DECK,an)
	local tmin=0
	local tmax=0
	if c:IsType(TYPE_MONSTER) then
		tmin,tmax=c:GetTributeRequirement()
	end
	Duel.ConfirmCards(tp,c)
	Duel.ConfirmCards(1-tp,c)
	if c:IsType(TYPE_MONSTER) and (c:IsSummonable(true,nil) or c:IsMSetable(true,nil)) and ((Duel.IsExistingMatchingCard(Card.IsReleasable,tp,LOCATION_MZONE,0,tmin,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>-tmin) or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tmin==0)) then
		local poi=0 --set/summon control variable
		if c:IsSummonable(true,nil) or c:IsMSetable(true,nil) then 
			poi=Duel.SelectOption(tp,1,1153)
		elseif c:IsSummonable(true,nil) then
			poi=0
		else
			poi=1
		end
		if poi==0 then
			Duel.DisableShuffleCheck()
			Duel.SendtoHand(c,tp,REASON_RULE)
			Duel.Summon(tp,c,true,nil)
		else
			Duel.DisableShuffleCheck()
			Duel.SendtoHand(c,tp,REASON_RULE)
			Duel.MSet(tp,c,true,nil)
		end
		if c:IsLocation(LOCATION_HAND) then
			Duel.DisableShuffleCheck()
			Duel.SendtoDeck(c,tp,an,REASON_RULE)
			forbidden[tp][an+1]=true
			Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(4002,9))
		else
			--re organize forbidden list
			for i=an+1,n do
				forbidden[tp][i]=forbidden[tp][i+1]
			end
		end
	else
		forbidden[tp][an+1]=true
		Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(4002,9))
	end
end
--spell
function s.spelltarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
end
function s.spelloperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local n=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local r={}
	for i=1,n do
		if not forbidden[tp][i] then table.insert(r,i) end
	end
	local an=Duel.AnnounceNumber(tp,table.unpack(r))-1
	local tc=Duel.GetFieldCard(tp,LOCATION_DECK,an)
	Duel.ConfirmCards(tp,tc)
	Duel.ConfirmCards(1-tp,tc)
	if tc:IsType(TYPE_SPELL) then
		local tpe=tc:GetType()
		local te=tc:GetActivateEffect()
		local tg=te:GetTarget()
		local co=te:GetCost()
		local op=te:GetOperation()
		if te:IsActivatable(tp) then
			e:SetCategory(te:GetCategory())
			e:SetProperty(te:GetProperty())
			Duel.ClearTargetCard()
			if (tpe&TYPE_FIELD)~=0 then
				local fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
				if Duel.GetFlagEffect(tp,62765383)>0 then
					if fc then Duel.Destroy(fc,REASON_RULE) end
					of=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
					if fc and Duel.Destroy(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
				else
					Duel.GetFieldCard(tp,LOCATION_SZONE,5)
					if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
				end
			end
			Duel.DisableShuffleCheck()
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			Duel.Hint(HINT_CARD,0,tc:GetCode())
			tc:CreateEffectRelation(te)
			if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
			if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
			Duel.BreakEffect()
			local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
			if g then
				local etc=g:GetFirst()
				while etc do
					etc:CreateEffectRelation(te)
					etc=g:GetNext()
				end
			end
			if op then
				if (tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 and not tc:IsHasEffect(EFFECT_REMAIN_FIELD) then
					tc:CancelToGrave(false)
				end
				if op then op(e,tp,eg,ep,ev,re,r,rp) end
			end
			tc:ReleaseEffectRelation(te)
			if etc then 
				etc=g:GetFirst()
				while etc do
					etc:ReleaseEffectRelation(te)
					etc=g:GetNext()
				end
			end
			--re organize forbidden list
			for i=an+1,n do
				forbidden[tp][i]=forbidden[tp][i+1]
			end
		else
			forbidden[tp][an+1]=true
			Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(4002,9))
		end
	else
		forbidden[tp][an+1]=true
		Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(4002,9))
	end
end
--trap
function s.traptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
end
function s.trapoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local n=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local r={}
	for i=1,n do
		if not forbidden[tp][i] then table.insert(r,i) end
	end
	local an=Duel.AnnounceNumber(tp,table.unpack(r))-1
	local tc=Duel.GetFieldCard(tp,LOCATION_DECK,an)
	Duel.ConfirmCards(tp,tc)
	Duel.ConfirmCards(1-tp,tc)
	if tc:IsType(TYPE_TRAP) then
		local tpe=tc:GetType()
		local te=tc:GetActivateEffect()
		local tg=te:GetTarget()
		local co=te:GetCost()
		local op=te:GetOperation()
		if te:IsActivatable(tp) then
			e:SetCategory(te:GetCategory())
			e:SetProperty(te:GetProperty())
			Duel.ClearTargetCard()
			Duel.DisableShuffleCheck()
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			if (tpe&TYPE_FIELD)~=0 then
				Duel.MoveSequence(tc,5)
			end
			Duel.Hint(HINT_CARD,0,tc:GetCode())
			tc:CreateEffectRelation(te)
			if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
			if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
			Duel.BreakEffect()
			local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
			if g then
				local etc=g:GetFirst()
				while etc do
					etc:CreateEffectRelation(te)
					etc=g:GetNext()
				end
			end
			if op then
				if (tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 and not tc:IsHasEffect(EFFECT_REMAIN_FIELD) then
					tc:CancelToGrave(false)
				end
				if op then op(e,tp,eg,ep,ev,re,r,rp) end
			end
			tc:ReleaseEffectRelation(te)
			if etc then 
				etc=g:GetFirst()
				while etc do
					etc:ReleaseEffectRelation(te)
					etc=g:GetNext()
				end
			end
			--re organize forbidden list
			for i=an+1,n do
				forbidden[tp][i]=forbidden[tp][i+1]
			end
		else
			forbidden[tp][an+1]=true
			Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(4002,9))
		end
	else
		forbidden[tp][an+1]=true
		Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(4002,9))
	end
end
--[[
	scripter note: not fully working, you can see monster by searching effect's
	also, need event deck shuffle
	the cost may be working wrong if it demand to dischard top card deck, because it may be turned on sending random card, since you don't have top deck card theoricaly
--]]
