--ヤモイモリ
--Yamoimori
--scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--Banish from GY + choice effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.btg)
	e1:SetOperation(s.bop)
	c:RegisterEffect(e1)
end
s.listed_names={id}
--Banish from GY + choice effect
function s.mfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsFaceup() and (c:IsCanChangePosition() or c:IsDestructable())
end
function s.mfilter2(c)
	return c:IsMonster() and c:IsFaceup() and (c:IsCanChangePosition() or c:GetAttack()>0)
end
function s.btg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.mfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingTarget(s.mfilter2,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc1=Duel.SelectTarget(tp,s.mfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc2=Duel.SelectTarget(tp,s.mfilter2,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	local pos,des,choice=tc1:IsCanChangePosition() and tc2:IsCanChangePosition(),tc1:IsDestructable() and tc2:GetAttack()>0,-1
	if pos and des then 
		choice=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
		elseif pos then choice=Duel.SelectOption(tp,aux.Stringid(id,1))
			elseif des then choice=Duel.SelectOption(tp,aux.Stringid(id,2))+1
			else return
	end
	if choice==0 then Duel.SetOperationInfo(0,CATEGORY_POSITION,Group.FromCards(tc1,tc2),2,tp,LOCATION_MZONE)
		elseif choice==1 then Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc1,1,tp,LOCATION_MZONE)
								Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tc2,1,tp,LOCATION_MZONE)
			else return
	end
	local a={}
	a[1],a[2],a[3]=tc1,tc2,choice
	e:SetLabelObject(a)
end
function s.bop(e,tp,eg,ep,ev,re,r,rp)
	local tc1,tc2,choice=e:GetLabelObject()[1],e:GetLabelObject()[2],e:GetLabelObject()[3]
	if not tc1 or not tc2 or not tc1:IsRelateToEffect(e) or not tc2:IsRelateToEffect(e) or choice==-1 then return end
	if (choice==0 and (not tc1:IsCanChangePosition() or not tc2:IsCanChangePosition())) or (choice==1 and (not tc1:IsDestructable() or tc2:GetAttack()==0)) then return end
	if choice==0 then
		Duel.ChangePosition(Group.FromCards(tc1,tc2),POS_FACEDOWN_DEFENSE)
	end
	if choice==1 then
		if Duel.Destroy(tc1,REASON_EFFECT)>0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc2:RegisterEffect(e1)
		end
	end
end