--神魔獣 ガーゼット
--God Maju Garzett
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	c:RegisterFlagEffect(FLAG_TRIPLE_TRIBUTE,0,0,1)
	--Summon with 3 tribute
	local e1=aux.AddNormalSummonProcedure(c,true,true,3,3,SUMMON_TYPE_TRIBUTE+1,aux.Stringid(id,0),aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT))
	--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--tribute check
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	local tc=g:GetFirst()
	local atk=0
	if #g<3 then
		local sg=g:Filter(Card.IsType,nil,TYPE_EFFECT)
		local tg=e:GetLabelObject()
		--It is impossible to get rid of the message that prompt a 3 Tribute using a Normal monster. FilterCount ensures that the effect is working correctly anyways.
		if #tg==1 and g:FilterCount(Card.IsNonEffectMonster,nil)==0 and c:IsSummonType(SUMMON_TYPE_TRIBUTE+1) then
			local tgc=tg:GetFirst()
			local catk=0
			catk=tgc:GetTextAttack()*2
			if tgc:IsMaximumMode() then
				catk=tgc.MaximumAttack*2
			end
			atk=atk+catk
			sg:RemoveCard(tgc)
			local tc=sg:GetFirst()
			if tc then
				atk=atk+tc:GetTextAttack()
			end
			atk=atk+800
		elseif #tg>1 and g:FilterCount(Card.IsNonEffectMonster,nil)==0 and c:IsSummonType(SUMMON_TYPE_TRIBUTE+1) then
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
			local dg=tg:Select(tp,1,1,nil)
			atk=atk+dg:GetFirst():GetTextAttack()*2
			sg:RemoveCard(dg:GetFirst())
			atk=atk+sg:GetFirst():GetTextAttack()+800
		elseif #g==1 and #tg==1 then
			local catk=0
			catk=tc:GetTextAttack()*2
			if tc:IsMaximumMode() then
				catk=tc.MaximumAttack*2
			end
			atk=atk+(catk>=0 and catk or 0)
		else
			for tc in sg:Iter() do
				local catk=0
				catk=tc:GetTextAttack()
				if tc:IsMaximumMode() then
					catk=tc.MaximumAttack*2
				end
				atk=atk+(catk>=0 and catk or 0)
			end
		end
	else
		for tc in g:Iter() do
			local catk=0
			if tc:IsType(TYPE_EFFECT) then
				catk=tc:GetTextAttack()
				if tc:IsMaximumMode() then
					catk=tc.MaximumAttack*2
				end
			end
			atk=atk+(catk>=0 and catk or 0)
		end
		atk=atk+800
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TOFIELD)
	c:RegisterEffect(e1)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if #g<3 then
		local sg=g:Filter(Card.IsType,nil,TYPE_EFFECT)
		local tg=sg:Filter(Card.HasFlagEffect,nil,FLAG_DOUBLE_TRIB)
		if #tg==0 then
			tg=sg:Filter(Card.HasFlagEffect,nil,FLAG_DOUBLE_TRIB_DARK+FLAG_DOUBLE_TRIB_FIEND+FLAG_DOUBLE_TRIB_0_ATK+FLAG_DOUBLE_TRIB_0_DEF+FLAG_DOUBLE_TRIB_EFFECT)
		end
		tg:KeepAlive()
		local label_obj=e:GetLabelObject() --this is e0
		label_obj:SetLabelObject(tg)
		return
	end
end