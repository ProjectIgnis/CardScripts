--サイコ・ブレイド
--Psychic Blade
local s,id=GetID()
function s.initial_effect(c)
	--Equip
	local e1=aux.AddEquipProcedure(c,nil,nil,nil,s.cost)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	--Equipped monster gain ATK/DEF equal to the LP paid
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		for _,te in ipairs({Duel.GetPlayerEffect(tp,EFFECT_LPCOST_CHANGE)}) do
			local value=te:GetValue()
			if value(te,e,tp,100)~=100 then return false end
		end
		return Duel.CheckLPCost(tp,100)
	end
	local lp=Duel.GetLP(tp)
	local m=math.floor(math.min(lp,2000)/100)
	local t={}
	for i=1,m do
		t[i]=i*100
	end
	local ac=Duel.AnnounceNumber(tp,table.unpack(t))
	Duel.PayLPCost(tp,ac)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1,ac)
end
function s.val(e,c)
	local ct=e:GetHandler():GetFlagEffectLabel(id)
	if not ct then return 0 end
	return ct
end