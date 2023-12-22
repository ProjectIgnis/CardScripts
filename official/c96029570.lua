--漆黒の太陽
--Ebon Sun
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Gain LP equal to the total original ATK of the monsters destroyed
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_RECOVER)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_CUSTOM+id)
	e1a:SetRange(LOCATION_SZONE)
	e1a:SetCountLimit(1,id)
	e1a:SetTarget(s.lptg)
	e1a:SetOperation(s.lpop)
	c:RegisterEffect(e1a)
	local g1=Group.CreateGroup()
	g1:KeepAlive()
	e1a:SetLabelObject(g1)
	--Keep track of the destroyed monsters
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1b:SetCode(EVENT_DESTROYED)
	e1b:SetRange(LOCATION_SZONE)
	e1b:SetLabelObject(e1a)
	e1b:SetOperation(s.atkregop)
	c:RegisterEffect(e1b)
	--Increase the ATK of 1 monster by 1000
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_ATKCHANGE)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2a:SetCode(EVENT_CUSTOM+id+1)
	e2a:SetRange(LOCATION_SZONE)
	e2a:SetCountLimit(1,{id,1})
	e2a:SetTarget(s.atktg)
	e2a:SetOperation(s.atkop)
	c:RegisterEffect(e2a)
	local g2=Group.CreateGroup()
	g2:KeepAlive()
	e2a:SetLabelObject(g2)
	--Register monsters Special Summoned from your GY
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2b:SetRange(LOCATION_SZONE)
	e2b:SetLabelObject(e2a)
	e2b:SetOperation(s.regsumop)
	c:RegisterEffect(e2b)
	--Add 1 discarded Spell/Trap to your hand
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,2))
	e3a:SetCategory(CATEGORY_TOHAND)
	e3a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3a:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3a:SetCode(EVENT_CUSTOM+id+2)
	e3a:SetRange(LOCATION_SZONE)
	e3a:SetCountLimit(1,{id,2})
	e3a:SetTarget(s.thtg)
	e3a:SetOperation(s.thop)
	c:RegisterEffect(e3a)
	local g3=Group.CreateGroup()
	g3:KeepAlive()
	e3a:SetLabelObject(g3)
	--Register discarded Spell/Traps
	local e3b=Effect.CreateEffect(c)
	e3b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3b:SetCode(EVENT_DISCARD)
	e3b:SetRange(LOCATION_SZONE)
	e3b:SetLabelObject(e3a)
	e3b:SetOperation(s.stregop)
	c:RegisterEffect(e3b)
end
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local value=e:GetLabelObject():GetSum(Card.GetBaseAttack)
	if chk==0 then return value>0 end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(value)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,value)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end
function s.desfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_BATTLE|REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
function s.atkregop(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(s.desfilter,nil,tp)
	if #tg>0 then
		for tc in tg:Iter() do
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
		end
		local g=e:GetLabelObject():GetLabelObject()
		if Duel.GetCurrentChain()==0 then g:Clear() end
		g:Merge(tg)
		g:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
		e:GetLabelObject():SetLabelObject(g)
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
function s.atkfilter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_MZONE)
		and c:IsSummonLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=e:GetLabelObject():Filter(s.atkfilter,nil,e,tp)
	if chkc then return g:IsContains(chkc) and chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc,e,tp) end
	if chk==0 then return #g>0 end
	local tc=nil
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
		tc=g:Select(tp,1,1,nil):GetFirst()
	else
		tc=g:GetFirst()
	end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,tp,1000)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		--Gains 1000 ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.regsumop(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(s.atkfilter,nil,e,tp)
	if #tg>0 then
		for tc in tg:Iter() do
			tc:RegisterFlagEffect(id+1,RESET_CHAIN,0,1)
		end
		local g=e:GetLabelObject():GetLabelObject()
		if Duel.GetCurrentChain()==0 then g:Clear() end
		g:Merge(tg)
		g:Remove(function(c) return c:GetFlagEffect(id+1)==0 end,nil)
		e:GetLabelObject():SetLabelObject(g)
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id+1,e,0,tp,tp,0)
	end
end
function s.thfilter(c,e,tp)
	return c:IsSpellTrap() and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_GRAVE)
		and c:IsAbleToHand() and c:IsControler(tp) and c:IsPreviousControler(tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=e:GetLabelObject():Filter(s.thfilter,nil,e,tp)
	if chkc then return g:IsContains(chkc) and s.cfilter(thfilter,e,tp) end
	if chk==0 then return #g>0 end
	local tc=nil
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		tc=g:Select(tp,1,1,nil):GetFirst()
	else
		tc=g:GetFirst()
	end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
function s.stregop(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(s.thfilter,nil,e,tp)
	if #tg>0 then
		for tc in tg:Iter() do
			tc:RegisterFlagEffect(id+2,RESET_CHAIN,0,1)
		end
		local g=e:GetLabelObject():GetLabelObject()
		if Duel.GetCurrentChain()==0 then g:Clear() end
		g:Merge(tg)
		g:Remove(function(c) return c:GetFlagEffect(id+2)==0 end,nil)
		e:GetLabelObject():SetLabelObject(g)
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id+2,e,0,tp,tp,0)
	end
end