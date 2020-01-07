--Predator Germination
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.tg(e,tp,eg,ev,ep,re,r,rp,chk)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local t1=Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE) and a and d and d:IsFaceup() and d:IsAttribute(ATTRIBUTE_DARK) and a:IsControler(1-tp)
	local t2=not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>2 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,511004422,0x10f3,TYPES_TOKEN,0,0,1,RACE_PLANT,ATTRIBUTE_DARK)
	if chk==0 then return t1 or t2 end
	e:SetCategory(0)
	e:SetProperty(0)
	local opt=0
	if t1 and t2 then
		opt=Duel.SelectOption(tp,aux.Stringid(67284107,0),aux.Stringid(33883834,0),aux.Stringid(37390589,2))
	elseif t1 then
		opt=Duel.SelectOption(tp,aux.Stringid(67284107,0))
	else
		opt=Duel.SelectOption(tp,aux.Stringid(33883834,0))+1
	end
	if opt==0 or opt==2 then
		e:SetCategory(e:GetCategory()+CATEGORY_DESTROY)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.SetTargetCard(d)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,a,1,0,0)
	end
	if opt==1 or opt==2 then
		e:SetCategory(e:GetCategory()+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,0)
	end
	Duel.SetTargetParam(opt)
end
function s.op(e,tp,eg,ev,ep,re,r,rp)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local opt=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if opt==0 or opt==2 then
		if d and d:IsRelateToEffect(e) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
			d:RegisterEffect(e1)
		end
		if a:IsRelateToBattle() then
			Duel.HintSelection(Group.FromCards(a))
			Duel.Destroy(a,REASON_EFFECT)
		end
	end
	if opt==1 or opt==2 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>2 
			and Duel.IsPlayerCanSpecialSummonMonster(tp,511004422,0x10f3,TYPES_TOKEN,0,0,1,RACE_PLANT,ATTRIBUTE_DARK) then
			for i=1,3 do
				local token=Duel.CreateToken(tp,511004422)
				Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			end
			Duel.SpecialSummonComplete()
		end
	end
end
