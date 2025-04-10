--朔夜しぐれ
--Ghost Mourner & Moonlit Chill
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	local g=Group.CreateGroup()
	g:KeepAlive()
	--Negate effects of a Special Summoned monster and inflict damage if it leaves the field this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfDiscard)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	e1:SetLabelObject(g)
	c:RegisterEffect(e1)
	--Register summons
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1a:SetRange(LOCATION_ALL)
	e1a:SetLabelObject(e1)
	e1a:SetOperation(s.regop)
	c:RegisterEffect(e1a)
end
function s.cfilter(c,e,tp)
	return c:IsSummonPlayer(1-tp) and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_MZONE) and (c:HasNonZeroAttack() or c:IsNegatableMonster())
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(s.cfilter,nil,e,tp)
	if #tg>0 then
		for tc in tg:Iter() do
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
		end
		local g=e:GetLabelObject():GetLabelObject()
		if Duel.GetCurrentChain()==0 then g:Clear() end
		g:Merge(tg)
		g:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
		e:GetLabelObject():SetLabelObject(g)
		if Duel.GetFlagEffect(tp,id)==0 then
			Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
			Duel.RaiseEvent(eg,EVENT_CUSTOM+id,e,0,tp,tp,0)
		end
	end
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=e:GetLabelObject():Filter(s.cfilter,nil,e,tp)
	if chkc then return g:IsContains(chkc) and s.cfilter(chkc,e,tp) end
	if chk==0 then return #g>0 end
	local tg=nil
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		tg=g:Select(tp,1,1,nil)
	else
		tg=g
	end
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc:IsNegatableMonster() then
		tc:NegateEffects(c,RESET_PHASE|PHASE_END)
	end
	if tc:IsFaceup() then
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT|RESET_MSCHANGE|RESET_OVERLAY|RESET_TURN_SET|RESET_PHASE|PHASE_END,0,1,fid)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_LEAVE_FIELD)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetOperation(s.leaveop)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.leaveop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if eg:IsContains(tc) and tc:GetFlagEffectLabel(id)==e:GetLabel() then
		local p=tc:GetPreviousControler()
		if Duel.Damage(p,tc:GetBaseAttack(),REASON_EFFECT)>0 then
			Duel.Hint(HINT_CARD,0,id)
		end
		tc:ResetFlagEffect(id)
		e:Reset()
	end
end