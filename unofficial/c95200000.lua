--Command Duel
local s,id=GetID()
function s.initial_effect(c)
	aux.EnableExtraRules(c,s,s.init)
end
function s.init(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCountLimit(1)
	e1:SetOperation(s.play)
	Duel.RegisterEffect(e1,0)
end
function s.play(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local ac
	local te
	local code
	local tc
	local p=Duel.GetTurnPlayer()
	while not te do
		ac=Duel.GetRandomNumber(1,#s.command)
		code=s.command[ac]
		tc=Duel.CreateToken(p,code)
		te=tc:GetActivateEffect()
	end
	if Duel.GetLocationCount(p,LOCATION_SZONE)<=0 then return end
	local tg=te:GetTarget()
	local co=te:GetCost()
	local op=te:GetOperation()
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	Duel.ClearTargetCard()
	if not tc:IsType(TYPE_FIELD) then
		local of=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
		if of then Duel.Destroy(of,REASON_RULE) end
		of=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		if of and Duel.Destroy(of,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
	end
	Duel.MoveToField(tc,p,p,LOCATION_SZONE,POS_FACEUP,true)
	Duel.Hint(HINT_CARD,0,tc:GetCode())
	Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(id,0))
	Duel.Hint(HINT_MESSAGE,1-tp,aux.Stringid(id,0))
	tc:CreateEffectRelation(te)
	if tc:IsType(TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 then
		tc:CancelToGrave(false)
	end
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
	if op then op(te,tp,eg,ep,ev,re,r,rp) end
	tc:ReleaseEffectRelation(te)
	if etc then	
		etc=g:GetFirst()
		while etc do
			etc:ReleaseEffectRelation(te)
			etc=g:GetNext()
		end
	end
	Duel.SendtoDeck(tc,nil,-2,REASON_RULE)
end
s.command = {
	95200001,95200002,95200003,95200004,95200005,95200006,95200007,95200008,95200009,
	95200010,95200011,95200012,95200013,95200014,95200015,95200016,95200017,95200018,
	95200019,95200020,95200021,95200022,95200023,95200024,95200025,95200101,95200102}
	
