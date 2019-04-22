--宣告者の神託
local s,id=GetID()
function s.initial_effect(c)
	local e1=aux.AddRitualProcGreaterCode(c,48546368)
	e1:SetTarget(s.target(e1))
end
function s.target(eff)
	local tg = eff:GetTarget()
	return function(e,...)
		local ret = tg(e,...)
		if ret then return ret end
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			Duel.SetChainLimit(s.chlimit)
		end
	end
end
function s.chlimit(e,ep,tp)
	return tp==ep
end