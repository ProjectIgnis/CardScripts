--The Sun of God Dragon
--マイケル・ローレンス・ディーによってスクリプト
--scripted by MLD
--credit to TPD & Cybercatman
--updated and currently maintained by Larry126
Duel.LoadScript("c421.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Summon With 3 Tributes
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(s.sumoncon)
	e1:SetOperation(s.sumonop)
	e1:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	c:RegisterEffect(e2)
	--Unstoppable Attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL) end)
	c:RegisterEffect(e3)
	--Resurrection
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(s.egpcon)
	e4:SetTarget(s.immortal)
	c:RegisterEffect(e4)
	--Stats When Normal Summoned
	local ea=Effect.CreateEffect(c)
	ea:SetType(EFFECT_TYPE_SINGLE)
	ea:SetCode(EFFECT_MATERIAL_CHECK)
	ea:SetValue(s.valcheck)
	c:RegisterEffect(ea)
	local ex=Effect.CreateEffect(c)
	ex:SetType(EFFECT_TYPE_SINGLE)
	ex:SetCode(EFFECT_SUMMON_COST)
	ex:SetLabelObject(ea)
	ex:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) e:GetLabelObject():SetLabel(1) end)
	c:RegisterEffect(ex)
	--Chanting
	local sum1=Effect.CreateEffect(c)
	sum1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	sum1:SetCode(EVENT_SUMMON_SUCCESS)
	sum1:SetOperation(s.sumop)
	c:RegisterEffect(sum1)
	local sum2=sum1:Clone()
	sum2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(sum2)
	local sum3=sum1:Clone()
	sum3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(sum3)
	local sum=Effect.CreateEffect(c)
	sum:SetType(EFFECT_TYPE_SINGLE)
	sum:SetCode(id)
	sum:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	c:RegisterEffect(sum)
	aux.GlobalCheck(s,function()
		--De-Fusion
		local df=Effect.CreateEffect(c)
		df:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		df:SetCode(EVENT_ADJUST)
		df:SetOperation(s.dfop)
		Duel.RegisterEffect(df,0)
	end)
end
s.listed_names={95286165,10000010,511000987}
--De-Fusion
function s.dffilter(c)
	if not c:IsCode(95286165) then return false end
	local effs={c:GetCardEffect()}
	for _,eff in ipairs(effs) do
		if eff:GetLabel()==608286299 then return false end
	end
	return true
end
function s.dfop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.dffilter,tp,0xff,0xff,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(tc)
		e1:SetDescription(aux.Stringid(4012,8))
		e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_RECOVER)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetCode(tc:GetActivateEffect():GetCode())
		e1:SetProperty(tc:GetActivateEffect():GetProperty()|EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(608286299)
		e1:SetTarget(s.tg)
		e1:SetOperation(s.op)
		tc:RegisterEffect(e1)
	end
end
function s.dffilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsCode(10000010)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.dffilter2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.dffilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.dffilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetAttack())
end
function s.tgfilter(c,tc)
	return c:IsHasCardTarget(tc)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	local atk=tc:GetAttack()
	tc:ResetEffect(RESET_LEAVE,RESET_EVENT)
	if tc:RegisterFlagEffect(236,RESET_EVENT+RESETS_STANDARD,0,1) then
		Duel.Recover(tp,atk,REASON_EFFECT)
		tc:ClearEffectRelation()
		local tg=Duel.GetMatchingGroup(s.tgfilter,tp,0xff,0xff,Group.FromCards(tc,c),tc)
		for ec in aux.Next(tg) do
			ec:CancelCardTarget(tc)
		end
		if c:IsOriginalCode(511000987) then
			Duel.BreakEffect()
			Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE,1)
		end
		if Duel.GetCurrentChain()<=1 then return end
		for i=1,Duel.GetCurrentChain()-1 do
			local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
			local g=Duel.GetChainInfo(i,CHAININFO_TARGET_CARDS)
			if te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and g:IsContains(tc) then
				local rg=Group.CreateGroup()
				rg:Merge(g)
				rg:RemoveCard(tc)
				Duel.ChangeTargetCard(i,rg)
			end
		end
	end
end
-------------------------------------------
--Summon With 3 Tributes
function s.sumoncon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>-3 and Duel.GetTributeCount(c)>=3
end
function s.sumonop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-------------------------------------------
--Resurrection
function s.egpcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
function s.immortal(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if s.payatkcost(e,tp,eg,ep,ev,re,r,rp,0) then
		local op=Duel.SelectOption(tp,aux.Stringid(4012,3),aux.Stringid(4012,4),aux.Stringid(4012,5))
		if op==0 then
			s.payatkcost(e,tp,eg,ep,ev,re,r,rp,1)
			e:SetOperation(s.payatkop)
		elseif op==1 then
			e:SetOperation(s.egpop)
		else
			e:SetOperation(nil)
		end
	else
		local op=Duel.SelectOption(tp,aux.Stringid(4012,4),aux.Stringid(4012,5))
		if op==0 then
			e:SetOperation(s.egpop)
		else
			e:SetOperation(nil)
		end
	end
end
-------------------------------------------
--Point to Point Transfer
function s.payatkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,2) end
	local lp=Duel.GetLP(tp)
	e:SetLabel(lp-1)
	Duel.PayLPCost(tp,lp-1)
end
function s.payatkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lp=e:GetLabel()
	if c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCondition(s.dfcon)
		e1:SetValue(c:GetBaseAttack()+lp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		e2:SetValue(c:GetBaseDefense()+lp)
		c:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_ADD_TYPE)
		e3:SetValue(TYPE_FUSION)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetCondition(s.dfcon)
		c:RegisterEffect(e3)
		local def=Effect.CreateEffect(c)
		def:SetCondition(s.dfcon)
		def:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(def)
		local e4=Effect.CreateEffect(c)
		e4:SetDescription(aux.Stringid(4012,6))
		e4:SetType(EFFECT_TYPE_QUICK_O)
		e4:SetCode(EVENT_FREE_CHAIN)
		e4:SetRange(LOCATION_MZONE)
		e4:SetCondition(s.dfcon)
		e4:SetCost(s.tatkcost)
		e4:SetOperation(s.tatkop)
		e4:SetLabelObject(def)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e4)
		--gain atk/def
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_RECOVER)
		e5:SetRange(LOCATION_MZONE)
		e5:SetCondition(s.dfcon)
		e5:SetOperation(s.atkop1)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e5)
		local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e6:SetCode(EVENT_CHAIN_END)
		e6:SetRange(LOCATION_MZONE)
		e6:SetCondition(s.dfcon)
		e6:SetOperation(s.atkop2)
		e6:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e6)
		local e7=Effect.CreateEffect(c)
		e7:SetType(EFFECT_TYPE_FIELD)
		e7:SetRange(LOCATION_MZONE)
		e7:SetTargetRange(0,LOCATION_MZONE)
		e7:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
		e7:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
		e7:SetCondition(s.dfcon)
		e7:SetTarget(function(e,c) return c:GetFlagEffect(id)>0 end)
		e7:SetValue(function(e,c) return c==e:GetHandler() end)
		e7:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e7)
		local e8=Effect.CreateEffect(c)
		e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e8:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
		e8:SetCode(EVENT_DAMAGE_STEP_END)
		e8:SetCondition(s.dircon)
		e8:SetOperation(s.dirop)
		e8:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e8)
		local e9=Effect.CreateEffect(c)
		e9:SetType(EFFECT_TYPE_SINGLE)
		e9:SetCode(EFFECT_EXTRA_ATTACK)
		e9:SetValue(9999)
		e9:SetCondition(s.dfcon)
		e9:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e9)
		local e10=Effect.CreateEffect(c)
		e10:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e10:SetCode(EVENT_DAMAGE_STEP_END)
		e10:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e10:SetCondition(s.uncon)
		e10:SetOperation(s.unop)
		e10:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e10)
	end
end
function s.atkop1(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp then return end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(ev)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetValue(ev)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
	Duel.SetLP(tp,1,REASON_EFFECT)
end
function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local lp=Duel.GetLP(tp)
	if lp<=1 then return end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(lp-1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetValue(lp-1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
	Duel.SetLP(tp,1,REASON_EFFECT)
end
function s.tatkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,1,false,nil,e:GetHandler()) end
	local g=Duel.SelectReleaseGroupCost(tp,nil,1,99,false,nil,e:GetHandler())
	local tc=g:GetFirst()
	local suma=0
	local sumd=0
	while tc do
		suma=suma+tc:GetAttack()
		sumd=sumd+tc:GetDefense()
		tc=g:GetNext()
	end
	e:SetLabel(suma)
	e:GetLabelObject():SetLabel(sumd)
	Duel.Release(g,REASON_COST)
end
function s.tatkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(236)>0 then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(e:GetLabel())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(e:GetLabelObject():GetLabel())
	e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e2)
end
function s.uncon(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	return bc and bc:IsRelateToBattle() and e:GetHandler():GetFlagEffect(236)<=0
end
function s.unop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	bc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
function s.dircon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttackTarget()==nil and Duel.GetAttacker()==e:GetHandler() and e:GetHandler():GetFlagEffect(236)<=0
end
function s.dirop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	e:GetHandler():RegisterEffect(e1)
end
function s.dfcon(e)
	return e:GetHandler():GetFlagEffect(236)<=0
end
-------------------------------------------
--Egyption God Phoenix
function s.egpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_EVENT+0x1fe1000+RESET_PHASE+PHASE_END)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(511000237)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(4012,7))
		e2:SetCategory(CATEGORY_TOGRAVE)
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCost(s.descost)
		e2:SetTarget(s.destg)
		e2:SetOperation(s.desop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
		--immune
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e3)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_INDESTRUCTABLE)
		e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SINGLE_RANGE)
		e4:SetRange(LOCATION_MZONE)
		e4:SetValue(1)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e4)
		local e5=e4:Clone()
		e5:SetCode(EFFECT_IMMUNE_EFFECT)
		e5:SetValue(s.imfilter)
		c:RegisterEffect(e5)
	end
end
function s.imfilter(e,te)
	if not te then return false end
	return te:IsHasCategory(CATEGORY_TOHAND+CATEGORY_DESTROY+CATEGORY_REMOVE+CATEGORY_TODECK+CATEGORY_RELEASE+CATEGORY_TOGRAVE)
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckLPCost(tp,1000) and ((not c:IsHasEffect(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		and not c:IsHasEffect(EFFECT_FORBIDDEN) and not c:IsHasEffect(EFFECT_CANNOT_ATTACK)
		and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_ATTACK_ANNOUNCE)
		and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_ATTACK))
		or c:IsHasEffect(EFFECT_UNSTOPPABLE_ATTACK)) end
	Duel.PayLPCost(tp,1000)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,LOCATION_MZONE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if not tc:GetFlagEffectLabel(513000065)
		or (c:GetFlagEffectLabel(513000065) and c:GetFlagEffectLabel(513000065)>=tc:GetFlagEffectLabel(513000065)) then
		e:SetProperty(e:GetProperty()|EFFECT_FLAG_IGNORE_IMMUNE)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CHAIN)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CHAIN)
		tc:RegisterEffect(e2,true)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetValue(function(e,te) return te:GetOwner()~=e:GetOwner() end)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CHAIN)
		tc:RegisterEffect(e3,true)
		Duel.AdjustInstantly(c)
	end
	Duel.SendtoGrave(tc,REASON_EFFECT)
	e:SetProperty(e:GetProperty()&~EFFECT_FLAG_IGNORE_IMMUNE)
end
-------------------------------------------
--Stats When Normal Summoned
function s.valcheck(e,c)
	local mg=c:GetMaterial()
	local atk=0
	local def=0
	for tc in aux.Next(mg) do
		local catk=tc:GetAttack()
		local cdef=tc:GetDefense()
		atk=atk+(catk>=0 and catk or 0)
		def=def+(cdef>=0 and cdef or 0)
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+0xff0000)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		e2:SetValue(def)
		c:RegisterEffect(e2)
	end
end
-------------------------------------------
--Chanting
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
--[[	local chant=true
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(4012,9))
	local op=Duel.SelectOption(tp,aux.Stringid(4012,10),aux.Stringid(4012,11),aux.Stringid(4012,12),aux.Stringid(4012,13),aux.Stringid(4012,14),aux.Stringid(4012,15))
	if op~=3 then
		local op2=Duel.SelectOption(1-tp,aux.Stringid(4012,10),aux.Stringid(4012,11),aux.Stringid(4012,12),aux.Stringid(4012,13),aux.Stringid(4012,14),aux.Stringid(4012,15))
		if op2~=3 then
			chant=false
		else
			if not Duel.GetControl(c,1-tp) then
				chant=false
			end
		end
	end
	if chant==false then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		c:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e3:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
		e3:SetRange(LOCATION_MZONE)
		c:RegisterEffect(e3)
	end
	Duel.BreakEffect()]]
	--control
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	e6:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e6)
end