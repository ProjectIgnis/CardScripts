--Fusion Party!
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon(Fusion.SummonEffTG()),s.flipop(Fusion.SummonEffOP{extraop=s.extraop}),1)
end
function s.flipcon(fustg)
	return function(e,tp,eg,ep,ev,re,r,rp)
		--opd check
		if Duel.GetFlagEffect(ep,id)>0 then return end
		--condition
		return aux.CanActivateSkill(tp) and fustg(e,tp,eg,ep,ev,re,r,rp,0)
	end
end
function s.extraop(e,tc,tp,mat)
	return tc:RegisterEffect(e:GetLabelObject())
end
function s.flipop(fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
		Duel.Hint(HINT_CARD,tp,id)
		Duel.RegisterFlagEffect(ep,id,0,0,0)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetOperation(function() Duel.SetChainLimitTillChainEnd(aux.FALSE) end)
		e:SetLabelObject(e1)
		fusop(e,tp,eg,ep,ev,re,r,rp)
		e1:Reset()
		e:SetLabelObject(nil)
	end
end
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
