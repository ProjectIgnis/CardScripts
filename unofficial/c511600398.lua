--オベリスクの巨神兵 (Anime)
--Obelisk the Tormentor (Anime)
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Summon with 3 Tribute
	aux.AddNormalSummonProcedure(c,true,false,3,3)
	aux.AddNormalSetProcedure(c,true,false,3,3)
	--Destroy Equip
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_EQUIP)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	--Control of this card cannot switch
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e2)
	--Effect immunity
	local e3=e2:Clone()
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e4:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_RITUAL))
	c:RegisterEffect(e4)
	--Last for 1 turn & block
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_TURN_END)
	e5:SetRange(LOCATION_MZONE)
	e5:SetOperation(s.stgop)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetOperation(s.spchk)
	c:RegisterEffect(e6)
	--Effect
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,0))
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(s.condition)
	e7:SetCost(s.cost)
	e7:SetTarget(s.target)
	e7:SetOperation(s.operation)
	c:RegisterEffect(e7)
	aux.GlobalCheck(s,function()
		--avatar
		local av=Effect.CreateEffect(c)
		av:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		av:SetCode(EVENT_ADJUST)
		av:SetCondition(s.avatarcon)
		av:SetOperation(s.avatarop)
		Duel.RegisterEffect(av,0)
	end)
end
function s.avfilter(c)
	local atktes={c:GetCardEffect(EFFECT_SET_ATTACK_FINAL)}
	local ae=nil
	local de=nil
	for _,atkte in ipairs(atktes) do
		if atkte:GetOwner()==c and atkte:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE)
				and atkte:IsHasProperty(EFFECT_FLAG_REPEAT)
				and atkte:IsHasProperty(EFFECT_FLAG_DELAY) then
			ae=atkte:GetLabel()
		end
	end
	local deftes={c:GetCardEffect(EFFECT_SET_DEFENSE_FINAL)}
	for _,defte in ipairs(deftes) do
		if defte:GetOwner()==c and defte:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE)
				and defte:IsHasProperty(EFFECT_FLAG_REPEAT)
				and defte:IsHasProperty(EFFECT_FLAG_DELAY) then
			de=defte:GetLabel()
		end
	end
	return c:IsOriginalCode(21208154) and (ae~=9999999 or de~=9999999)
end
function s.avatarcon(e,tp,eg,ev,ep,re,r,rp)
	return Duel.GetMatchingGroupCount(s.avfilter,tp,0xff,0xff,nil)>0
end
function s.avatarop(e,tp,eg,ev,ep,re,r,rp)
	local g=Duel.GetMatchingGroup(s.avfilter,tp,0xff,0xff,nil)
	g:ForEach(function(c)
		local atktes={c:GetCardEffect(EFFECT_SET_ATTACK_FINAL)}
		for _,atkte in ipairs(atktes) do
			if atkte:GetOwner()==c and atkte:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE)
				and atkte:IsHasProperty(EFFECT_FLAG_REPEAT)
				and atkte:IsHasProperty(EFFECT_FLAG_DELAY) then
				atkte:SetValue(s.avaval)
				atkte:SetLabel(9999999)
			end
		end
		local deftes={c:GetCardEffect(EFFECT_SET_DEFENSE_FINAL)}
		for _,defte in ipairs(deftes) do
			if defte:GetOwner()==c and defte:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE)
				and defte:IsHasProperty(EFFECT_FLAG_REPEAT)
				and defte:IsHasProperty(EFFECT_FLAG_DELAY) then
				defte:SetValue(s.avaval)
				defte:SetLabel(9999999)
			end
		end
	end)
end
function s.avafilter(c)
	return c:IsFaceup() and c:GetCode()~=21208154
end
function s.avaval(e,c)
	local g=Duel.GetMatchingGroup(s.avafilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 then
		return 100
	else
		local tg,val=g:GetMaxGroup(Card.GetAttack)
		if val>=9999999 then
			return val
		else
			return val+100
		end
	end
end
-----------------------------------------------------------------
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Destroy(eg:Filter(function(ec) return ec:GetEquipTarget()==c end,nil),REASON_EFFECT)
end
function s.leaveChk(c,category)
	local ex,tg=Duel.GetOperationInfo(0,category)
	return ex and tg~=nil and tg:IsContains(c)
end
function s.efilter(e,te,c)
	local c=e:GetOwner()
	local tc=te:GetOwner()
	return (te:IsTrapEffect() and te:IsActivated())
		or (((te:IsSpellEffect() and te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):IsContains(c))
		or (te:IsMonsterEffect() and tc~=c and not tc:IsOriginalAttribute(ATTRIBUTE_DIVINE)))
		and ((c:GetDestination()>0 and c:GetReasonEffect()==te)
		or (s.leaveChk(c,CATEGORY_TOHAND) or s.leaveChk(c,CATEGORY_DESTROY) or s.leaveChk(c,CATEGORY_REMOVE)
		or s.leaveChk(c,CATEGORY_TODECK) or s.leaveChk(c,CATEGORY_RELEASE) or s.leaveChk(c,CATEGORY_TOGRAVE))))
end
function s.stgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local effs={c:GetCardEffect()}
	for _,eff in ipairs(effs) do
		if eff:GetOwner()~=c and not eff:GetOwner():IsCode(0)
			and not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE) and eff:GetCode()~=EFFECT_SPSUMMON_PROC
			and (eff:GetTarget()==aux.PersistentTargetFilter or not eff:IsHasType(EFFECT_TYPE_GRANT+EFFECT_TYPE_FIELD)) then
			eff:Reset()
		end
	end
end
function s.spchk(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re and (re:IsSpellEffect() or re:IsMonsterEffect()) then
		local prevCtrl=c:GetPreviousControler()
		aux.DelayedOperation(c,PHASE_END,id,e,tp,function()
			if c:IsPreviousLocation(LOCATION_GRAVE) then
				Duel.SendtoGrave(c,REASON_EFFECT,prevCtrl)
			elseif c:IsPreviousLocation(LOCATION_DECK) then
				Duel.SendtoDeck(c,prevCtrl,SEQ_DECKSHUFFLE,REASON_EFFECT)
			elseif c:IsPreviousLocation(LOCATION_HAND) then
				Duel.SendtoHand(c,prevCtrl,REASON_EFFECT)
			elseif c:IsPreviousLocation(LOCATION_REMOVED) then
				Duel.Remove(c,c:GetPreviousPosition(),REASON_EFFECT,prevCtrl)
			elseif c:GetPreviousLocation()==0 then
				Duel.RemoveCards(c)
			end
		end,nil,0)
	end
	if c:IsAttackPos() then return end
	local ac=Duel.GetAttacker()
	if Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE) and ac:CanAttack()
		and ac:GetAttackableTarget():IsContains(c)
		and Duel.SelectEffectYesNo(tp,c,aux.Stringid(68823957,0)) then
		Duel.HintSelection(c,true)
		Duel.ChangeAttackTarget(c)
	end
	local te,tg=Duel.GetChainInfo(ev+1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TARGET_CARDS)
	if te and te~=re and te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and #tg==1
		and c:IsCanBeEffectTarget(te) and Duel.SelectEffectYesNo(tp,c,aux.Stringid(68823957,1)) then
		Duel.ChangeTargetCard(ev+1,Group.FromCards(c))
	end
end
-----------------------------------------------------------------
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsBattlePhase() and Duel.GetCurrentChain()==0 and (not c:IsHasEffect(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		and not c:IsHasEffect(EFFECT_FORBIDDEN) and not c:IsHasEffect(EFFECT_CANNOT_ATTACK)
		and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_ATTACK_ANNOUNCE)
		and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_ATTACK)
		or c:IsHasEffect(EFFECT_UNSTOPPABLE_ATTACK))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,2,false,nil,e:GetHandler()) end
	local g=Duel.SelectReleaseGroupCost(tp,nil,2,2,false,nil,e:GetHandler())
	Duel.Release(g,REASON_COST)
end
function s.desfilter(c,atk)
	return c:IsFacedown() or c:IsAttackPos() and c:IsAttackBelow(atk) or c:IsDefensePos() and c:IsDefenseBelow(atk)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CanAttack() end
	local op=Duel.SelectEffect(tp,
		{true,aux.Stringid(id,1)},
		{true,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DESTROY)
		local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,e:GetHandler():GetAttack())
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_ATKCHANGE)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local op=e:GetLabel()
	if op==1 then
		Duel.Destroy(Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,c:GetAttack()),REASON_EFFECT)
		if c:CanAttack() then
			Duel.CalculateDamage(c,nil)
		end
	elseif op==2 and c:CanAttack() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE|PHASE_BATTLE|RESET_CHAIN)
		e1:SetValue(s.adval)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
		e2:SetCondition(s.damcon)
		e2:SetOperation(s.damop)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE|PHASE_BATTLE|RESET_CHAIN)
		c:RegisterEffect(e2)
		local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
		if #g==0 or ((c:IsHasEffect(EFFECT_DIRECT_ATTACK) or not g:IsExists(aux.NOT(Card.IsHasEffect),1,nil,EFFECT_IGNORE_BATTLE_TARGET)) and Duel.SelectYesNo(tp,31)) then
			Duel.CalculateDamage(c,nil)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACKTARGET)
			Duel.CalculateDamage(c,g:Select(tp,1,1,nil):GetFirst())
		end
	end
end
function s.adval(e,c)
	local g=Duel.GetMatchingGroup(nil,0,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	if #g==0 then
		return 9999999
	else
		local tg,val=g:GetMaxGroup(Card.GetAttack)
		if val<=9999999 then
			return 9999999
		else
			return val
		end
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and e:GetHandler():GetAttack()>=9999999
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,Duel.GetLP(ep)*100)
end