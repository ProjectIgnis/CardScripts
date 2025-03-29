--ヤモイモリ
--Yamorimori
--scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfBanish)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
function s.tgfilter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsFaceup()
		and ((c:IsControler(tp) and c:IsRace(RACE_REPTILE))
		or (c:IsControler(1-tp) and (c:IsCanTurnSet() or c:GetAttack()>0)))
end
function s.rescon(sg,e,tp,mg)
	if sg:GetClassCount(Card.GetControler)~=2 then return false end
	local opp_c=sg:Filter(Card.IsControler,nil,1-tp):GetFirst()
	return sg:FilterCount(Card.IsCanTurnSet,nil)==2 or opp_c:GetAttack()>0
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_FACEUP)
	Duel.SetTargetCard(tg)
	local self_g,opp_g=tg:Split(Card.IsControler,nil,tp)
	local b1=tg:IsExists(Card.IsCanTurnSet,2,nil)
	local b2=opp_g:GetFirst():GetAttack()>0
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	if op==1 then
		e:SetCategory(CATEGORY_POSITION)
		e:SetLabelObject(nil)
		Duel.SetOperationInfo(0,CATEGORY_POSITION,tg,2,tp,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
		e:SetLabelObject(self_g:GetFirst())
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,self_g,1,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,opp_g,1,tp,0)
	end
	e:SetLabel(op)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g==0 then return end
	local op=e:GetLabel()
	if op==1 then
		--Change those monsters to face-down Defense Position
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	elseif op==2 then
		--Destroy that monster you control and change the ATK of the other monster to 0
		local self_c=e:GetLabelObject()
		local opp_c=g:RemoveCard(self_c):GetFirst()
		if self_c:IsRelateToEffect(e) and self_c:IsControler(tp) and Duel.Destroy(self_c,REASON_EFFECT)>0
			and opp_c and opp_c:IsRelateToEffect(e) and opp_c:IsFaceup() then
			--Change its ATK to 0
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			opp_c:RegisterEffect(e1)
		end
	end
end