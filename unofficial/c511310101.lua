--ダークネス １
--Darkness 1
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
s.listed_names={511310104,511310105}
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:GetHandler():GetFlagEffect(511310104)~=0 and Duel.GetCurrentChain()==1 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
	end
end 
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:GetFlagEffect(511310104)~=0 then
		if Duel.GetCurrentChain()==1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
			if #g==0 then return end
			local dg=g:Select(tp,1,1,nil)
			if Duel.Destroy(dg,REASON_EFFECT)~=0 then
				g:Sub(dg)
				local ct=0
				if Duel.GetFlagEffect(tp,511310102)~=0 then ct=ct+1 end
				if Duel.GetFlagEffect(tp,511310103)~=0 then ct=ct+1 end
				if ct>0 and #g>0 then
					Duel.BreakEffect()
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
					local g2=dg:Select(tp,ct,ct,nil)
					if #g2>0 then
						Duel.Destroy(g2,REASON_EFFECT)
					end
				end
			end
		else
			Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,0)
		end
	end
end
