--ペネトレーション・フュ ージョン
--Penetration Fusion
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,nil,nil,s.fextra)
	c:RegisterEffect(e1)
	--ATK Gain
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
		--battle destroy
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DESTROYING)
		ge1:SetOperation(s.bdop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
function s.ffilter(c,e)
	return c:GetReasonEffect() and c:GetReasonEffect():GetHandler()==e:GetHandler()
		and c:IsReleasableByEffect() and Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,c)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ffilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,e) end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,500)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local fc=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_MZONE,0,1,1,nil,e):GetFirst()
	if fc and Duel.Release(fc,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local pc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if pc then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			pc:RegisterEffect(e1)
		end
	end
end
function s.bdop(e,tp,eg,ep,ev,re,r,rp)
	eg:GetFirst():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
end
function s.filterchk(c,tp)
	return c:GetFlagEffect(id)>0 and c:IsControler(tp) and c:IsOnField()
end
function s.fcheck(tp,sg,fc,mg)
	return sg:IsExists(s.filterchk,1,nil,tp)
end
function s.fextra(e,tp,mg)
	return nil,s.fcheck
end