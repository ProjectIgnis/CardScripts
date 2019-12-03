--多次元壊獣ラディアン
--Radian, the Multidimensional Kaiju
local s,id=GetID()
function s.initial_effect(c)
	local e1,e2=aux.AddKaijuProcedure(c)
	--token
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.tkcost)
	e3:SetTarget(s.tktg)
	e3:SetOperation(s.tkop)
	c:RegisterEffect(e3)
end
s.counter_list={0x37}
s.listed_series={0xd3}
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x37,2,REASON_COST) end
	Duel.RemoveCounter(tp,1,1,0x37,2,REASON_COST)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,2800,0,7,RACE_FIEND,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,2800,0,7,RACE_FIEND,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,id+1)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		token:RegisterEffect(e1,true)
	end
end
